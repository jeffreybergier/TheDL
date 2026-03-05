#import "TDLURLConnectionService.h"
#import "TDLDownload.h"
#import "TDLDownloadList.h"
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
  NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request 
                                                                delegate:self];
  if (connection) {
    // Create a live TDLDownload object via the shared list
    TDLDownload *download = [[TDLDownloadList sharedList] createDownload];
    [download setRequestURL:[url absoluteString]];
    [download setServiceIdentifier:[self serviceIdentifier]];
    [download setState:TDLDownloadStateDownloading];
    [download setDisplayName:[[url absoluteString] lastPathComponent]];
    
    // Set up file path for live data
    NSString *downloadsDir = [[TDLDownloadList sharedList] downloadsDirectory];
    NSString *dataPath = [downloadsDir stringByAppendingPathComponent:[[download udid] stringByAppendingPathExtension:@"data"]];
    [download setFilePath:dataPath];
    
    // Ensure data file is empty/created
    [[NSData data] writeToFile:dataPath atomically:YES];
    
    [[TDLDownloadList sharedList] saveDownload:download];
    
    [_activeTasks setObject:download forKey:[NSValue valueWithPointer:connection]];
    [_taskList addObject:download];
  }
  [connection release];
}

- (NSArray *)activeTasks {
  // Return only tasks belonging to this service that are not finished
  NSMutableArray *tasks = [NSMutableArray array];
  for (TDLDownload *download in _taskList) {
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
    // Append data to live file
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:[download filePath]];
    [handle seekToEndOfFile];
    [handle writeData:data];
    [handle closeFile];
    
    [download setActualSize:[download actualSize] + [data length]];
    
    // Optional: Save metadata periodically or every chunk
    [[TDLDownloadList sharedList] saveDownload:download];
  }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  TDLDownload *download = [_activeTasks objectForKey:[NSValue valueWithPointer:connection]];
  if (download) {
    [download setState:TDLDownloadStateFailed];
    [download setErrorMessage:[error localizedDescription]];
    [[TDLDownloadList sharedList] saveDownload:download];
    [_activeTasks removeObjectForKey:[NSValue valueWithPointer:connection]];
  }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  TDLDownload *download = [_activeTasks objectForKey:[NSValue valueWithPointer:connection]];
  if (download) {
    [download setState:TDLDownloadStateFinished];
    [[TDLDownloadList sharedList] saveDownload:download];
    [_activeTasks removeObjectForKey:[NSValue valueWithPointer:connection]];
  }
}

@end
