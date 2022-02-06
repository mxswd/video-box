import http.server
import socketserver

DIRECTORY = "."

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

def run(path, server_class=http.server.HTTPServer):
    global DIRECTORY
    DIRECTORY = path
    server_address = ('', 8000)
    httpd = server_class(server_address, Handler)
    httpd.serve_forever()
