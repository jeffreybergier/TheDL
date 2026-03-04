#import "TDLURLConnectionService.h"
#import "TDLDownloadTask.h"
#import "TDLDownload.h"
#include <TargetConditionals.h>

@implementation TDLURLConnectionService

+ (TDLURLConnectionService *)sharedService {
  static TDLURLConnectionService *sharedInstance = nil;
  if (!sharedInstance) {
    sharedInstance = [[TDLURLConnectionService alloc] init];
  }
  return sharedInstance;
}

- (id)init {
  self = [super init];
  if (self) {
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
  return @"NSURLConnection";
}

- (NSString *)serviceIdentifier {
  return @"com.kumasan.thedl.service.urlconnection";
}

- (void)fetchURL:(NSURL *)url {
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  // Using initWithRequest:delegate: for compatibility
  NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request 
                                                                delegate:self];
  if (connection) {
    TDLDownloadTask *task = [[TDLDownloadTask alloc] initWithURL:url];
    // Map connection to task (NSURLConnection does not implement NSCopying, so we use pointer value as key)
    [_activeTasks setObject:task forKey:[NSValue valueWithPointer:connection]];
    [_taskList addObject:task];
    [task release];
  }
  [connection release];
}

- (NSArray *)activeTasks {
  return _taskList;
}

#pragma mark - NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  TDLDownloadTask *task = [_activeTasks objectForKey:[NSValue valueWithPointer:connection]];
  if (task) {
    [task setSuggestedFilename:[response suggestedFilename]];
    [task setContentType:[response MIMEType]];
  }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  TDLDownloadTask *task = [_activeTasks objectForKey:[NSValue valueWithPointer:connection]];
  if (task) {
    [[task accumulatedData] appendData:data];
  }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  TDLDownloadTask *task = [_activeTasks objectForKey:[NSValue valueWithPointer:connection]];
  if (task) {
    [task setState:TDLDownloadTaskStateFailed];
    [task setErrorMessage:[error localizedDescription]];
    [_activeTasks removeObjectForKey:[NSValue valueWithPointer:connection]];
  }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  TDLDownloadTask *task = [_activeTasks objectForKey:[NSValue valueWithPointer:connection]];
  if (task) {
    [task setState:TDLDownloadTaskStateFinished];
    
    // Get Downloads directory path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [paths objectAtIndex:0];
    NSString *downloadsDir = [docsDir stringByAppendingPathComponent:@"Downloads"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
#if !TARGET_OS_IPHONE && defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && __MAC_OS_X_VERSION_MIN_REQUIRED < 1050
    if ([fm respondsToSelector:@selector(createDirectoryAtPath:attributes:)]) {
      [fm performSelector:@selector(createDirectoryAtPath:attributes:) 
               withObject:downloadsDir 
               withObject:nil];
    }
#else
    [fm createDirectoryAtPath:downloadsDir withIntermediateDirectories:YES attributes:nil error:nil];
#endif
    
    // Save data blob
    NSString *udid = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *dataPath = [downloadsDir stringByAppendingPathComponent:[udid stringByAppendingPathExtension:@"data"]];
    [[task accumulatedData] writeToFile:dataPath atomically:YES];
    
    // Create TDLDownload object and save its metadata as PLIST
    TDLDownload *download = [[TDLDownload alloc] init];
    [download setDisplayName:[task suggestedFilename]];
    [download setFilePath:dataPath];
    [download setContentType:[task contentType]];
    [download setRequestURL:[[task url] absoluteString]];
    [download setActualSize:[[task accumulatedData] length]];
    [download setContentSize:[[task accumulatedData] length]];
    
    NSString *plistPath = [downloadsDir stringByAppendingPathComponent:[udid stringByAppendingPathExtension:@"plist"]];
    [[download dictionaryRepresentation] writeToFile:plistPath atomically:YES];
    
    [download release];
    [_activeTasks removeObjectForKey:[NSValue valueWithPointer:connection]];
  }
}

@end
