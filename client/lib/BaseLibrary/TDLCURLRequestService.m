#import "TDLCURLRequestService.h"
#import "TDLDownload.h"
#import "TDLDownloadList.h"
#import "XPCURLRequest.h"

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
  
  // Ensure file exists
  [[NSData data] writeToFile:dataPath atomically:YES];
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
  
  NSData *responseData = [XPCURLRequest performRequestWithURL:url
                                                       method:@"GET"
                                                      headers:nil
                                                         body:nil
                                                        error:&error];
  
  if (error) {
    NSLog(@"[TDLCURLRequestService] Failed: %@", [error localizedDescription]);
    [download setState:TDLDownloadStateFailed];
    [download setErrorMessage:[error localizedDescription]];
  } else {
    NSLog(@"[TDLCURLRequestService] Finished: %@", [download udid]);
    
    // Save data
    [responseData writeToFile:[download filePath] atomically:YES];
    
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
