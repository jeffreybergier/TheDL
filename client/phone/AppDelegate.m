#import "AppDelegate.h"
#import "RootViewController.h"

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
  NSLog(@"[AppDelegate application:didFinishLaunchingWithOptions:] Started TheDL on iOS.");
  
  _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  [_window setBackgroundColor:[UIColor whiteColor]];
  
  _rootViewController = [[RootViewController alloc] init];
  
  [_window addSubview:[_rootViewController view]];
  [_window makeKeyAndVisible];
  
  return YES;
}

- (void)dealloc {
  [_rootViewController release];
  [_window release];
  [super dealloc];
}

@end
