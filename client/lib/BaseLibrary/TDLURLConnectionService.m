#import "TDLURLConnectionService.h"
#import "TDLDownload.h"
#import "TDLDownloadList.h"
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
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request 
                                                                delegate:self];
  if (connection) {
    TDLDownload *download = [[TDLDownloadList sharedList] createDownload];
    [download setRequestURL:[url absoluteString]];
    [download setServiceIdentifier:[self serviceIdentifier]];
    [download setState:TDLDownloadStateDownloading];
    [download setDisplayName:[[url absoluteString] lastPathComponent]];
    
    NSString *downloadsDir = [[TDLDownloadList sharedList] downloadsDirectory];
    NSString *dataPath = [downloadsDir stringByAppendingPathComponent:[[download udid] stringByAppendingPathExtension:@"mp4"]];
    [download setFilePath:dataPath];
    
    // Ensure file exists
    [[NSData data] writeToFile:dataPath atomically:YES];
    
    [[TDLDownloadList sharedList] saveDownload:download];
    
    [_activeTasks setObject:download forKey:[NSValue valueWithPointer:connection]];
    [_taskList addObject:download];
  }
  [connection release];
}

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

#pragma mark - NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  TDLDownload *download = [_activeTasks objectForKey:[NSValue valueWithPointer:connection]];
  if (download) {
    NSLog(@"[TDLURLConnectionService] Received response for %@", [download udid]);
    [download setDisplayName:[response suggestedFilename]];
    [download setContentType:[response MIMEType]];
    [download setContentSize:[response expectedContentLength]];
    [download setResponseURL:[[response URL] absoluteString]];
    [[TDLDownloadList sharedList] saveDownload:download];
  }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  TDLDownload *download = [_activeTasks objectForKey:[NSValue valueWithPointer:connection]];
  if (download) {
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:[download filePath]];
    [handle seekToEndOfFile];
    [handle writeData:data];
    [handle closeFile];
    
    [download setActualSize:[download actualSize] + [data length]];
    [[TDLDownloadList sharedList] saveDownload:download];
  }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  TDLDownload *download = [_activeTasks objectForKey:[NSValue valueWithPointer:connection]];
  if (download) {
    NSLog(@"[TDLURLConnectionService] Failed: %@", [error localizedDescription]);
    [download setState:TDLDownloadStateFailed];
    [download setErrorMessage:[error localizedDescription]];
    [[TDLDownloadList sharedList] saveDownload:download];
    [_activeTasks removeObjectForKey:[NSValue valueWithPointer:connection]];
  }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  TDLDownload *download = [_activeTasks objectForKey:[NSValue valueWithPointer:connection]];
  if (download) {
    NSLog(@"[TDLURLConnectionService] Finished: %@", [download udid]);
    [download setState:TDLDownloadStateFinished];
    [[TDLDownloadList sharedList] saveDownload:download];
    [_activeTasks removeObjectForKey:[NSValue valueWithPointer:connection]];
  }
}

@end
