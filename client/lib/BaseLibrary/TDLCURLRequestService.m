#import "TDLCURLRequestService.h"
#import "TDLDownload.h"
#import "TDLDownloadList.h"
#import "TDLDownloadTask.h"
#import "XPCURLRequest.h"

#if THEDL_CURL_ENABLED

@implementation TDLCURLRequestService

- (id)initWithDownloadList:(TDLDownloadList *)downloadList {
  self = [super init];
  if (self) {
    _downloadList = [downloadList retain];
    _activeTasks = [[NSMutableDictionary alloc] init];
    _taskList = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)dealloc {
  [_activeTasks release];
  [_taskList release];
  [super dealloc];
}

- (NSString *)serviceName {
  return @"CURLRequest";
}

- (NSString *)serviceIdentifier {
  return @"com.kumasan.thedl.service.curl";
}

- (void)fetchURL:(NSURL *)url {
  NSLog(@"[TDLCURLRequestService fetchURL:] %@", url);
  
  TDLDownload *metadata = [[TDLDownload alloc] init];
  [metadata setRequestURL:[url absoluteString]];
  [metadata setServiceIdentifier:[self serviceIdentifier]];
  [metadata setState:TDLDownloadStateDownloading];
  
  NSURL *fileURL = [_downloadList targetURLForDownloadURL:url];
  NSString *dataPath = [fileURL path];
  
  // Create empty file
  [[NSData data] writeToFile:dataPath atomically:YES];
  
  // Save initial metadata so UI knows we are downloading
  [_downloadList saveDownload:metadata forURL:fileURL];
  
  TDLDownloadTask *task = [[TDLDownloadTask alloc] initWithTargetURL:fileURL metadata:metadata];
  [metadata release];
  
  XPCURLRequest *request = [[XPCURLRequest alloc] initWithURL:url
                                                       method:@"GET"
                                                      headers:nil
                                                         body:nil];
  [request setDelegate:self];
  
  // Map request to task
  [_activeTasks setObject:task forKey:[NSValue valueWithPointer:request]];
  [_taskList addObject:fileURL];
  
  [task release];

  // Perform CURL request on a background thread as it's blocking
  [NSThread detachNewThreadSelector:@selector(startRequest:) 
                           toTarget:self 
                         withObject:request];
  [request release];
}

- (void)startRequest:(XPCURLRequest *)request {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  [request start];
  [pool drain];
}

- (NSArray *)activeTasks {
  return [NSArray array];
}

#pragma mark - XPCURLRequestDelegate

- (void)xpcRequest:(XPCURLRequest *)request didReceiveResponse:(NSDictionary *)responseHeaders {
  TDLDownloadTask *task = [_activeTasks objectForKey:[NSValue valueWithPointer:request]];
  if (task) {
    TDLDownload *metadata = [task metadata];
    NSString *contentType = [responseHeaders objectForKey:@"content-type"];
    if (contentType) {
      NSRange semicolonRange = [contentType rangeOfString:@";"];
      if (semicolonRange.location != NSNotFound) {
        contentType = [contentType substringToIndex:semicolonRange.location];
      }
      [metadata setContentType:contentType];
    }
    
    NSString *contentLength = [responseHeaders objectForKey:@"content-length"];
    if (contentLength) {
      [metadata setContentSize:[contentLength longLongValue]];
    }
    
    // Save metadata immediately so UI can show percentage if content-length is known
    [_downloadList saveDownload:metadata forURL:[task targetFileURL]];
  }
}

- (void)xpcRequest:(XPCURLRequest *)request didReceiveData:(NSData *)data {
  TDLDownloadTask *task = [_activeTasks objectForKey:[NSValue valueWithPointer:request]];
  if (task) {
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingToURL:[task targetFileURL] error:nil];
    [handle seekToEndOfFile];
    [handle writeData:data];
    [handle closeFile];
    
    // Persist metadata to trigger notification
    [_downloadList saveDownload:[task metadata] forURL:[task targetFileURL]];
  }
}

- (void)xpcRequest:(XPCURLRequest *)request didFailWithError:(NSError *)error {
  TDLDownloadTask *task = [_activeTasks objectForKey:[NSValue valueWithPointer:request]];
  if (task) {
    TDLDownload *metadata = [task metadata];
    [metadata setState:TDLDownloadStateFailed];
    [metadata setErrorMessage:[error localizedDescription]];
    
    [_downloadList saveDownload:metadata forURL:[task targetFileURL]];
    [_activeTasks removeObjectForKey:[NSValue valueWithPointer:request]];
  }
}

- (void)xpcRequestDidFinishLoading:(XPCURLRequest *)request {
  TDLDownloadTask *task = [_activeTasks objectForKey:[NSValue valueWithPointer:request]];
  if (task) {
    TDLDownload *metadata = [task metadata];
    [metadata setState:TDLDownloadStateFinished];
    
    // Fallback content size if not set via headers
    if ([metadata contentSize] == 0) {
      NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:[[task targetFileURL] path] error:nil];
      [metadata setContentSize:[attrs fileSize]];
    }
    
    [_downloadList saveDownload:metadata forURL:[task targetFileURL]];
    [_activeTasks removeObjectForKey:[NSValue valueWithPointer:request]];
  }
}

@end

#endif
