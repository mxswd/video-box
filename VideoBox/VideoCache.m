//
//  VideoCache.m
//  VideoBox
//
//  Created by Maxwell on 21/06/21.
//

#import "VideoCache.h"
#import "Python.h"

// FIXME: rewrite this part

static YDL_progressUpdate progressUpdate;

static NSDictionary *parseJSON(char *json) {
    NSData *data = [NSData dataWithBytes:json length:strlen(json)];
    
    NSError *error;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        NSLog(@"Error deserializing JSON: %@", error);
        return NULL;
    } else {
        return result;
    }
}

static PyObject *callback(PyObject *o, PyObject *args) {
    NSLog(@"Callback ran!");
    
    char *status;
    PyArg_ParseTuple(args, "s", &status);
    if (progressUpdate) {
        progressUpdate(parseJSON(status));
    }

    Py_RETURN_NONE;
}

PyMethodDef progressCallback = { "progressCallback", callback, METH_VARARGS, NULL };

void YDL_setProgressCallback(YDL_progressUpdate callback) {
    progressUpdate = callback;
}

@implementation VideoCache

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *pythonHome = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"PythonHome"];
        Py_SetPythonHome(Py_DecodeLocale(pythonHome.UTF8String, NULL));
        Py_Initialize();
        
        PyObject *path = PySys_GetObject("path");
        PyList_Append(path, PyUnicode_FromString(pythonHome.UTF8String));
        
        
    }
    return self;
}

- (void)runWeb {
    PyObject *moduleName = PyUnicode_FromString("webgo");
    PyObject *module = PyImport_Import(moduleName);
    Py_DecRef(moduleName);
    PyErr_Print();
    
    PyObject *functionName = PyUnicode_FromString("run");
    PyObject *function = PyObject_GetAttr(module, functionName);
    
    Py_DecRef(functionName);
    Py_DecRef(module);
    NSURL *documentsDir = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    PyObject_CallFunction(function, "s", documentsDir.path.UTF8String);
    Py_DecRef(function);
    PyErr_Print();
}

- (void)download:(NSURL *)url outputDir:(NSURL *)outputDir {
    PyObject *moduleName = PyUnicode_FromString("downloader");
    PyObject *module = PyImport_Import(moduleName);
    Py_DecRef(moduleName);
    
    PyObject *progress = PyCFunction_New(&progressCallback, NULL);
    
    PyObject *functionName = PyUnicode_FromString("download");
    PyObject *function = PyObject_GetAttr(module, functionName);
    
    Py_DecRef(functionName);
    Py_DecRef(module);
    PyObject_CallFunction(function, "ssO", url.absoluteString.UTF8String, [outputDir.path stringByAppendingPathComponent:@"%(title)s-%(id)s.%(ext)s"].UTF8String, progress);
    Py_DecRef(function);
}

@end
