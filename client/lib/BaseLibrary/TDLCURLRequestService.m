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
  
  TDLDownload *metadata = [[TDLDownload alloc] init];
  [metadata setRequestURL:[url absoluteString]];
  [metadata setServiceIdentifier:[self serviceIdentifier]];
  [metadata setState:TDLDownloadStateDownloading];
  
  NSString *lastComponent = [[url path] lastPathComponent];
  if (!lastComponent || [lastComponent length] == 0) {
    lastComponent = @"download.data";
  }
  
  NSString *downloadsDir = [TDLDownloadList downloadsDirectory];
  NSString *dataPath = [downloadsDir stringByAppendingPathComponent:lastComponent];
  
  // Deduplicate using " (2)" format
  if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
    NSString *base = [lastComponent stringByDeletingPathExtension];
    NSString *ext = [lastComponent pathExtension];
    int counter = 2;
    while ([[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
      NSString *newName = [NSString stringWithFormat:@"%@ (%d)", base, counter];
      if ([ext length] > 0) {
        newName = [newName stringByAppendingPathExtension:ext];
      }
      dataPath = [downloadsDir stringByAppendingPathComponent:newName];
      counter++;
    }
  }
  
  // Ensure directory exists
  [[NSFileManager defaultManager] createDirectoryAtPath:downloadsDir 
                            withIntermediateDirectories:YES 
                                             attributes:nil 
                                                  error:NULL];
  
  // Create empty file so we have a target
  [[NSData data] writeToFile:dataPath atomically:YES];
  
  NSURL *fileURL = [NSURL fileURLWithPath:dataPath];
  [_taskList addObject:fileURL];

  // Perform CURL request on a background thread
  // We pass a dictionary with metadata and fileURL
  NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                        metadata, @"metadata",
                        fileURL, @"fileURL", nil];
  [metadata release];

  [NSThread detachNewThreadSelector:@selector(performFetchWithInfo:) 
                           toTarget:self 
                         withObject:info];
#else
  NSLog(@"[TDLCURLRequestService] CURL is disabled for this target. Cannot fetch: %@", url);
#endif
}

#if THEDL_CURL_ENABLED
- (void)performFetchWithInfo:(NSDictionary *)info {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  TDLDownload *metadata = [info objectForKey:@"metadata"];
  NSURL *fileURL = [info objectForKey:@"fileURL"];
  
  NSError *error = nil;
  NSURL *url = [NSURL URLWithString:[metadata requestURL]];
  NSDictionary *responseHeaders = nil;
  
  NSData *responseData = [XPCURLRequest performRequestWithURL:url
                                                       method:@"GET"
                                                      headers:nil
                                                         body:nil
                                              responseHeaders:&responseHeaders
                                                        error:&error];
  
  if (error) {
    NSLog(@"[TDLCURLRequestService] Failed: %@", [error localizedDescription]);
    [metadata setState:TDLDownloadStateFailed];
    [metadata setErrorMessage:[error localizedDescription]];
    [[TDLDownloadList sharedList] saveDownload:metadata forURL:fileURL];
  } else {
    NSLog(@"[TDLCURLRequestService] Finished: %@", [fileURL lastPathComponent]);
    
    // Save data
    BOOL success = [responseData writeToURL:fileURL atomically:YES];
    if (!success) {
      NSLog(@"[TDLCURLRequestService] ERROR: Could not write data to path: %@", [fileURL path]);
    }
    
    // Set metadata from headers
    NSString *contentType = [responseHeaders objectForKey:@"Content-Type"];
    if (contentType) {
      NSRange semicolonRange = [contentType rangeOfString:@";"];
      if (semicolonRange.location != NSNotFound) {
        contentType = [contentType substringToIndex:semicolonRange.location];
      }
      [metadata setContentType:contentType];
    }
    
    [metadata setContentSize:[responseData length]];
    [metadata setState:TDLDownloadStateFinished];
    
    // SAVE TO RESOURCE FORK
    [[TDLDownloadList sharedList] saveDownload:metadata forURL:fileURL];
  }
  
  [pool drain];
}
#endif

- (NSArray *)activeTasks {
  return [NSArray array];
}

@end

#endif
