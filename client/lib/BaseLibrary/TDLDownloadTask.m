#import "TDLDownloadTask.h"
#import "TDLDownload.h"

@implementation TDLDownloadTask

- (id)initWithTargetURL:(NSURL *)fileURL metadata:(TDLDownload *)download {
  self = [super init];
  if (self) {
    _targetFileURL = [fileURL retain];
    _metadata = [download retain];
  }
  return self;
}

- (void)dealloc {
  [_targetFileURL release];
  [_metadata release];
  [_connection release];
  [super dealloc];
}

- (NSURL *)targetFileURL { return _targetFileURL; }
- (TDLDownload *)metadata { return _metadata; }

- (NSURLConnection *)connection { return _connection; }
- (void)setConnection:(NSURLConnection *)connection {
  if (_connection != connection) {
    [_connection release];
    _connection = [connection retain];
  }
}

@end
