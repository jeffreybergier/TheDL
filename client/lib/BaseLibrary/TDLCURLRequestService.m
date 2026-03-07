#import "TDLCURLRequestService.h"
#import "TDLDownload.h"
#import "TDLDownloadList.h"
#import "XPCURLRequest.h"

#if THEDL_CURL_ENABLED

@implementation TDLCURLRequestService

+ (TDLCURLRequestService *)sharedService {
  static TDLCURLRequestService *sharedInstance = nil;
  if (!sharedInstance) {
    sharedInstance = [[TDLCURLRequestService alloc] init];
  }
  return sharedInstance;
}

- (id)init {
  self = [super init];
  if (self) {
    _taskList = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)dealloc {
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
#if THEDL_CURL_ENABLED
  NSLog(@"[TDLCURLRequestService fetchURL:] %@", url);
  
  TDLDownload *download = [[TDLDownloadList sharedList] createDownload];
  [download setRequestURL:[url absoluteString]];
  [download setServiceIdentifier:[self serviceIdentifier]];
  [download setState:TDLDownloadStateDownloading];
  [download setDisplayName:[[url absoluteString] lastPathComponent]];
  
  NSString *host = [url host] ? [url host] : @"unknown";
  NSString *lastComponent = [url lastPathComponent];
  if (!lastComponent || [lastComponent length] == 0 || [lastComponent isEqualToString:@"/"]) {
    lastComponent = @"download.data";
  }
  
  NSString *fileName = [NSString stringWithFormat:@"%@-%@", host, lastComponent];
  NSString *downloadsDir = [[TDLDownloadList sharedList] downloadsDirectory];
  NSString *dataPath = [downloadsDir stringByAppendingPathComponent:fileName];
  [download setFilePath:dataPath];
  
  // Ensure directory exists
  [[NSFileManager defaultManager] createDirectoryAtPath:downloadsDir 
                            withIntermediateDirectories:YES 
                                             attributes:nil 
                                                  error:NULL];
  
  [[TDLDownloadList sharedList] saveDownload:download];
  [_taskList addObject:download];

  // Perform CURL request on a background thread
  [NSThread detachNewThreadSelector:@selector(performFetchForDownload:) 
                           toTarget:self 
                         withObject:download];
#else
  NSLog(@"[TDLCURLRequestService] CURL is disabled for this target. Cannot fetch: %@", url);
#endif
}

#if THEDL_CURL_ENABLED
- (void)performFetchForDownload:(TDLDownload *)download {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  NSError *error = nil;
  NSURL *url = [NSURL URLWithString:[download requestURL]];
  NSDictionary *responseHeaders = nil;
  
  NSData *responseData = [XPCURLRequest performRequestWithURL:url
                                                       method:@"GET"
                                                      headers:nil
                                                         body:nil
                                              responseHeaders:&responseHeaders
                                                        error:&error];
  
  if (error) {
    NSLog(@"[TDLCURLRequestService] Failed: %@", [error localizedDescription]);
    [download setState:TDLDownloadStateFailed];
    [download setErrorMessage:[error localizedDescription]];
  } else {
    NSLog(@"[TDLCURLRequestService] Finished: %@", [download udid]);
    
    // Save data
    BOOL success = [responseData writeToFile:[download filePath] atomically:YES];
    if (!success) {
      NSLog(@"[TDLCURLRequestService] ERROR: Could not write data to path: %@", [download filePath]);
    }
    
    // Set metadata from headers
    NSString *contentType = [responseHeaders objectForKey:@"Content-Type"];
    if (contentType) {
      // Strip charset if present
      NSRange semicolonRange = [contentType rangeOfString:@";"];
      if (semicolonRange.location != NSNotFound) {
        contentType = [contentType substringToIndex:semicolonRange.location];
      }
      [download setContentType:contentType];
    }
    
    [download setActualSize:[responseData length]];
    [download setContentSize:[responseData length]];
    [download setState:TDLDownloadStateFinished];
  }
  
  [[TDLDownloadList sharedList] saveDownload:download];
  
  [pool drain];
}
#endif

- (NSArray *)activeTasks {
  NSMutableArray *tasks = [NSMutableArray array];
  NSEnumerator *e = [_taskList objectEnumerator];
  TDLDownload *download;
  while ((download = [e nextObject])) {
    if ([download state] == TDLDownloadStateDownloading || [download state] == TDLDownloadStateFailed) {
      [tasks addObject:download];
    }
  }
  return tasks;
}

@end

#endif
