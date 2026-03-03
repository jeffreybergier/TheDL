#import "GTMiOSAppDelegate.h"
#import "RootViewController.h"

@implementation GTMiOSAppDelegate

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
  NSLog(@"[GTMiOSAppDelegate application:didFinishLaunchingWithOptions:] Started TheDL on iOS.");
  
  _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  [_window setBackgroundColor:[UIColor whiteColor]];
  
  _rootViewController = [[RootViewController alloc] init];
  _navigationController = [[UINavigationController alloc] initWithRootViewController:_rootViewController];
  
  [_window addSubview:[_navigationController view]];
  [_window makeKeyAndVisible];
  
  return YES;
}

- (void)dealloc {
  [_navigationController release];
  [_rootViewController release];
  [_window release];
  [super dealloc];
}

@end
