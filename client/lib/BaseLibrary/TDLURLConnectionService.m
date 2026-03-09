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

/**
 * Returns a shared background thread for network operations.
 */
+ (void)networkThreadEntryPoint:(id)__unused object {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  [[NSThread currentThread] setName:@"TDLNetworkThread"];
  
  NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
  [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
  [runLoop run];
  
  [pool drain];
}

+ (NSThread *)networkThread {
  static NSThread *_networkThread = nil;
  
  // Note: dispatch_once is technically 10.6+ / iOS 4.0+, 
  // but for very old systems we can use a synchronized block.
  @synchronized(self) {
    if (_networkThread == nil) {
      _networkThread = [[NSThread alloc] initWithTarget:self 
                                                selector:@selector(networkThreadEntryPoint:) 
                                                  object:nil];
      [_networkThread start];
    }
  }
  return _networkThread;
}

- (id)init {
  self = [super init];
  if (self) {
    _activeTasks = [[NSMutableDictionary alloc] init];
    _taskList = [[NSMutableArray alloc] init];
#ifdef DEBUG
    NSLog(@"[TDLURLConnectionService] DEBUG mode active. Download throttling enabled.");
#else
    NSLog(@"[TDLURLConnectionService] RELEASE mode active. No throttling.");
#endif
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

/**
 * Helper to start connection on the network thread.
 */
- (void)startConnection:(NSURLConnection *)connection {
  [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  [connection start];
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
  // Create empty file
  [[NSData data] writeToFile:dataPath atomically:YES];
  NSURL *fileURL = [NSURL fileURLWithPath:dataPath];
  
  // Save initial metadata so UI knows we are downloading
  [[TDLDownloadList sharedList] saveDownload:metadata forURL:fileURL];
  
  TDLDownloadTask *task = [[TDLDownloadTask alloc] initWithTargetURL:fileURL metadata:metadata];
  [metadata release];
  
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request 
                                                                delegate:self 
                                                        startImmediately:NO];
  if (connection) {
    [task setConnection:connection];
    
    @synchronized(_activeTasks) {
      [_activeTasks setObject:task forKey:[NSValue valueWithPointer:connection]];
      [_taskList addObject:fileURL];
    }
    
    [self performSelector:@selector(startConnection:) 
                 onThread:[[self class] networkThread] 
               withObject:connection 
            waitUntilDone:NO];
  }
  
  [task release];
  [connection release];
}

- (NSArray *)activeTasks {
  return [NSArray array];
}

#pragma mark - NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  TDLDownloadTask *task = nil;
  @synchronized(_activeTasks) {
    task = [_activeTasks objectForKey:[NSValue valueWithPointer:connection]];
  }
  if (task) {
    TDLDownload *metadata = [task metadata];
    [metadata setContentType:[response MIMEType]];
    [metadata setContentSize:[response expectedContentLength]];
    [metadata setResponseURL:[[response URL] absoluteString]];
    
    // Save metadata immediately so UI can show percentage if content-length is known
    [[TDLDownloadList sharedList] saveDownload:metadata forURL:[task targetFileURL]];
  }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  TDLDownloadTask *task = nil;
  @synchronized(_activeTasks) {
    task = [_activeTasks objectForKey:[NSValue valueWithPointer:connection]];
  }
  if (task) {
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingToURL:[task targetFileURL] error:nil];
    [handle seekToEndOfFile];
    [handle writeData:data];
    [handle closeFile];

    // Persist metadata to trigger notification
    [[TDLDownloadList sharedList] saveDownload:[task metadata] forURL:[task targetFileURL]];

#ifdef DEBUG
    // LOG CHUNK
    NSLog(@"[TDLURLConnectionService] Received chunk: %lu bytes", (unsigned long)[data length]);
    // Aggressive slow down (500ms per chunk)
    usleep(500000); 
#endif
  }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  TDLDownloadTask *task = nil;
  @synchronized(_activeTasks) {
    task = [_activeTasks objectForKey:[NSValue valueWithPointer:connection]];
  }
  if (task) {
    TDLDownload *metadata = [task metadata];
    [metadata setState:TDLDownloadStateFailed];
    [metadata setErrorMessage:[error localizedDescription]];
    
    // Save metadata even on failure if we have a file
    [[TDLDownloadList sharedList] saveDownload:metadata forURL:[task targetFileURL]];
    
    @synchronized(_activeTasks) {
      [_activeTasks removeObjectForKey:[NSValue valueWithPointer:connection]];
    }
  }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  TDLDownloadTask *task = nil;
  @synchronized(_activeTasks) {
    task = [_activeTasks objectForKey:[NSValue valueWithPointer:connection]];
  }
  if (task) {
    TDLDownload *metadata = [task metadata];
    [metadata setState:TDLDownloadStateFinished];
    
    // SAVE TO RESOURCE FORK
    [[TDLDownloadList sharedList] saveDownload:metadata forURL:[task targetFileURL]];
    
    @synchronized(_activeTasks) {
      [_activeTasks removeObjectForKey:[NSValue valueWithPointer:connection]];
    }
  }
}

@end
