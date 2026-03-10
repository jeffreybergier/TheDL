#import "AppDelegate.h"
#import "CrossPlatform.h"
#import "TDLDownloadList.h"
#import "TDLServiceManager.h"

@implementation AppDelegate

- (NSWindow *)window {
  return _window;
}

- (void)setWindow:(NSWindow *)window {
  if (_window != window) {
    [_window release];
    _window = [window retain];
  }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  NSLog(@"[AppDelegate applicationDidFinishLaunching:] Started TheDL on macOS.");
  XPLogLibraryVersions();

  // Initialize Managers
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *downloadsPath = [documentsDirectory stringByAppendingPathComponent:@"Downloads"];
  NSURL *downloadsURL = [NSURL fileURLWithPath:downloadsPath];
  
  _downloadList = [[TDLDownloadList alloc] initWithDownloadsDirectoryURL:downloadsURL];
  _serviceManager = [[TDLServiceManager alloc] initWithDownloadList:_downloadList];

  NSRect frame = NSMakeRect(0, 0, 480, 320);
  unsigned int styleMask = NSTitledWindowMask | NSClosableWindowMask |
                         NSMiniaturizableWindowMask | NSResizableWindowMask;

  _window = [[NSWindow alloc] initWithContentRect:frame
                                       styleMask:styleMask
                                         backing:NSBackingStoreBuffered
                                           defer:NO];
  [_window setTitle:@"TheDL"];
  [_window center];
  [_window makeKeyAndOrderFront:nil];
}

- (void)dealloc {
  [_window release];
  [_downloadList release];
  [_serviceManager release];
  [super dealloc];
}

@end
