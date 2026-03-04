#import "TDLDownloadTask.h"

@implementation TDLDownloadTask

- (id)initWithURL:(NSURL *)url {
  self = [super init];
  if (self) {
    _url = [url retain];
    _state = TDLDownloadTaskStateRunning;
    _accumulatedData = [[NSMutableData alloc] init];
  }
  return self;
}

- (void)dealloc {
  [_url release];
  [_accumulatedData release];
  [_errorMessage release];
  [_suggestedFilename release];
  [_contentType release];
  [super dealloc];
}

- (NSURL *)url { return _url; }
- (TDLDownloadTaskState)state { return _state; }
- (void)setState:(TDLDownloadTaskState)state { _state = state; }

- (NSMutableData *)accumulatedData { return _accumulatedData; }
- (NSString *)errorMessage { return _errorMessage; }
- (void)setErrorMessage:(NSString *)error {
  if (_errorMessage != error) {
    [_errorMessage release];
    _errorMessage = [error copy];
  }
}

- (NSString *)suggestedFilename { return _suggestedFilename; }
- (void)setSuggestedFilename:(NSString *)filename {
  if (_suggestedFilename != filename) {
    [_suggestedFilename release];
    _suggestedFilename = [filename copy];
  }
}

- (NSString *)contentType { return _contentType; }
- (void)setContentType:(NSString *)type {
  if (_contentType != type) {
    [_contentType release];
    _contentType = [type copy];
  }
}

@end
