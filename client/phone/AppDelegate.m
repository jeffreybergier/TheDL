#import "AppDelegate.h"
#import "RootViewController.h"
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
  
  _rootViewController = [[RootViewController alloc] init];
  NSLog(@"[AppDelegate application:didFinishLaunchingWithOptions:] RootViewController created");
  
  // setRootViewController: is iOS 4.0+, use addSubview: for 3.1 compatibility
  if ([_window respondsToSelector:@selector(setRootViewController:)]) {
    [_window setRootViewController:_rootViewController];
  } else {
    [_window addSubview:[_rootViewController view]];
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
