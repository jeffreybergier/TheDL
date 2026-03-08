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

- (UITabBarController *)tabBarController {
  return _tabBarController;
}

- (void)setTabBarController:(UITabBarController *)controller {
  if (_tabBarController != controller) {
    [_tabBarController release];
    _tabBarController = [controller retain];
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
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:downloadVC];
  [downloadVC release];
  
  _tabBarController = [[UITabBarController alloc] init];
  [_tabBarController setViewControllers:[NSArray arrayWithObject:nav]];
  [nav release];
  
  NSLog(@"[AppDelegate application:didFinishLaunchingWithOptions:] TabBarController created");
  
  if ([_window respondsToSelector:@selector(setRootViewController:)]) {
    [_window setRootViewController:_tabBarController];
  } else {
    [_window addSubview:[_tabBarController view]];
  }
  
  [_window makeKeyAndVisible];
  
  NSLog(@"[AppDelegate application:didFinishLaunchingWithOptions:] Finished");
  return YES;
}

- (void)dealloc {
  [_tabBarController release];
  [_window release];
  [super dealloc];
}

@end
