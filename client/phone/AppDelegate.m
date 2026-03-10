#import "AppDelegate.h"
#import "TDLDownloadTableViewController.h"
#import "CrossPlatform.h"
#import "TDLDownloadList.h"
#import "TDLServiceManager.h"

@implementation AppDelegate

- (TDLDownloadList *)downloadList {
  return _downloadList;
}

- (TDLServiceManager *)serviceManager {
  return _serviceManager;
}

- (UIWindow *)window {
  return _window;
}

- (void)setWindow:(UIWindow *)window {
  if (_window != window) {
    [_window release];
    _window = [window retain];
  }
}

- (UINavigationController *)navigationController {
  return _navigationController;
}

- (void)setNavigationController:(UINavigationController *)controller {
  if (_navigationController != controller) {
    [_navigationController release];
    _navigationController = [controller retain];
  }
}

- (BOOL)application:(UIApplication *)application 
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  NSLog(@"[AppDelegate application:didFinishLaunchingWithOptions:] Start");
  
  // Verify libcurl/CrossPlatform linking
  XPLogLibraryVersions();
  
  // Initialize Managers
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *downloadsPath = [documentsDirectory stringByAppendingPathComponent:@"Downloads"];
  NSURL *downloadsURL = [NSURL fileURLWithPath:downloadsPath];
  
  _downloadList = [[TDLDownloadList alloc] initWithDownloadsDirectoryURL:downloadsURL];
  _serviceManager = [[TDLServiceManager alloc] initWithDownloadList:_downloadList];
  
  _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  [_window setBackgroundColor:[UIColor whiteColor]];
  
  TDLDownloadTableViewController *downloadVC = [[TDLDownloadTableViewController alloc] initWithDownloadList:_downloadList 
                                                                                             serviceManager:_serviceManager];
  _navigationController = [[UINavigationController alloc] initWithRootViewController:downloadVC];
  [downloadVC release];
  
  NSLog(@"[AppDelegate application:didFinishLaunchingWithOptions:] NavigationController created");
  
  if ([_window respondsToSelector:@selector(setRootViewController:)]) {
    [_window setRootViewController:_navigationController];
  } else {
    [_window addSubview:[_navigationController view]];
  }
  
  [_window makeKeyAndVisible];
  
  NSLog(@"[AppDelegate application:didFinishLaunchingWithOptions:] Finished");
  return YES;
}

- (void)dealloc {
  [_navigationController release];
  [_window release];
  [_downloadList release];
  [_serviceManager release];
  [super dealloc];
}

@end
