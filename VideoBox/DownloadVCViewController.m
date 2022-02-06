//
//  DownloadVCViewController.m
//  VideoBox
//
//  Created by Maxwell on 21/06/21.
//

#import "DownloadVCViewController.h"
#import "VideoCache.h"
#import "AppDelegate.h"
#import "Video+CoreDataClass.h"

static VideoCache *videoCache;

@interface DownloadVCViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end

@implementation DownloadVCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    self.cancelButton.enabled = NO;
    self.saveButton.enabled = NO;
    self.progressView.hidden = NO;
    self.progressView.progress = 0.0;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        videoCache = [VideoCache new];
    });
    
    __block NSString *title;
    __block NSString *filepath;
    YDL_setProgressCallback(^(NSDictionary * _Nonnull updateData) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"%@", updateData);
            NSNumber *downloaded = updateData[@"downloaded_bytes"];
            NSNumber *total = updateData[@"total_bytes"];
            self.progressView.progress = downloaded.floatValue / total.floatValue;
            title = [updateData[@"filename"] lastPathComponent];
            filepath = [updateData[@"filename"] lastPathComponent];
            
            if ([updateData[@"status"] isEqual:@"finished"]) {
                Video *video = [[Video alloc] initWithContext:((AppDelegate *)UIApplication.sharedApplication.delegate).persistentContainer.viewContext];
                video.filename = filepath;
                video.title = title;
                video.created = [NSDate date];
                video.url = self.urlField.text;
                NSError *e;
                
                [((AppDelegate *)UIApplication.sharedApplication.delegate).persistentContainer.viewContext obtainPermanentIDsForObjects:@[video] error:nil];
                [((AppDelegate *)UIApplication.sharedApplication.delegate).persistentContainer.viewContext save:&e];
                
                if (e != nil) {
                    NSLog(@"%@", e);
                }
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        });
    });
    NSString *url = self.urlField.text;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *documentsDir = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
        [videoCache download:[NSURL URLWithString:url] outputDir:documentsDir];
    });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
