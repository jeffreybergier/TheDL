#import "TDLURLConnectionService.h"
#import "TDLDownload.h"
#import "TDLDownloadList.h"
#import "TDLDownloadTask.h"
#import "CrossPlatform.h"

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
  NSLog(@"[TDLURLConnectionService fetchURL:] %@", url);
  
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
  
  // Deduplicate
  if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
    NSString *timestamp = [NSString stringWithFormat:@"-%ld", (long)[[NSDate date] timeIntervalSince1970]];
    NSString *base = [lastComponent stringByDeletingPathExtension];
    NSString *ext = [lastComponent pathExtension];
    dataPath = [downloadsDir stringByAppendingPathComponent:[[base stringByAppendingString:timestamp] stringByAppendingPathExtension:ext]];
  }
  
  // Create empty file
  [[NSData data] writeToFile:dataPath atomically:YES];
  NSURL *fileURL = [NSURL fileURLWithPath:dataPath];
  
  TDLDownloadTask *task = [[TDLDownloadTask alloc] initWithTargetURL:fileURL metadata:metadata];
  [metadata release];
  
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request 
                                                                delegate:self];
  if (connection) {
    [task setConnection:connection];
    [_activeTasks setObject:task forKey:[NSValue valueWithPointer:connection]];
    [_taskList addObject:fileURL];
  }
  
  [task release];
  [connection release];
}

- (NSArray *)activeTasks {
  return [NSArray array];
}

#pragma mark - NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  TDLDownloadTask *task = [_activeTasks objectForKey:[NSValue valueWithPointer:connection]];
  if (task) {
    TDLDownload *metadata = [task metadata];
    [metadata setContentType:[response MIMEType]];
    [metadata setContentSize:[response expectedContentLength]];
    [metadata setResponseURL:[[response URL] absoluteString]];
  }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  TDLDownloadTask *task = [_activeTasks objectForKey:[NSValue valueWithPointer:connection]];
  if (task) {
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingToURL:[task targetFileURL] error:nil];
    [handle seekToEndOfFile];
    [handle writeData:data];
    [handle closeFile];
  }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  TDLDownloadTask *task = [_activeTasks objectForKey:[NSValue valueWithPointer:connection]];
  if (task) {
    TDLDownload *metadata = [task metadata];
    [metadata setState:TDLDownloadStateFailed];
    [metadata setErrorMessage:[error localizedDescription]];
    
    // Save metadata even on failure if we have a file
    [[TDLDownloadList sharedList] saveDownload:metadata forURL:[task targetFileURL]];
    
    [_activeTasks removeObjectForKey:[NSValue valueWithPointer:connection]];
  }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  TDLDownloadTask *task = [_activeTasks objectForKey:[NSValue valueWithPointer:connection]];
  if (task) {
    TDLDownload *metadata = [task metadata];
    [metadata setState:TDLDownloadStateFinished];
    
    // SAVE TO RESOURCE FORK
    [[TDLDownloadList sharedList] saveDownload:metadata forURL:[task targetFileURL]];
    
    [_activeTasks removeObjectForKey:[NSValue valueWithPointer:connection]];
  }
}

@end
