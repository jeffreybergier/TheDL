#import "AppDelegate.h"
#import "TDLDownloadTableViewController.h"
#import "CrossPlatform.h"

@implementation AppDelegate

- (UIWindow *)window {
  return _window;
}

- (void)setWindow:(UIWindow *)window {
  if (_window != window) {
    [_window release];
    _window = [window retain];
  }
}

- (BOOL)application:(UIApplication *)application 
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  NSLog(@"[AppDelegate application:didFinishLaunchingWithOptions:] Start");
  
  // Verify libcurl/CrossPlatform linking
  XPLogLibraryVersions();
  
  _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  [_window setBackgroundColor:[UIColor whiteColor]];
  
  TDLDownloadTableViewController *downloadVC = [[TDLDownloadTableViewController alloc] init];
  _rootViewController = (id)[[UINavigationController alloc] initWithRootViewController:downloadVC];
  [downloadVC release];
  
  NSLog(@"[AppDelegate application:didFinishLaunchingWithOptions:] Root NavigationController created");
  
  if ([_window respondsToSelector:@selector(setRootViewController:)]) {
    [_window setRootViewController:(id)_rootViewController];
  } else {
    [_window addSubview:[(id)_rootViewController view]];
  }
  
  [_window makeKeyAndVisible];
  
  NSLog(@"[AppDelegate application:didFinishLaunchingWithOptions:] Finished");
  return YES;
}

- (void)dealloc {
  [_rootViewController release];
  [_window release];
  [super dealloc];
}

@end
