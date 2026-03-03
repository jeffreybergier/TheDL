#import "GTMiOSAppDelegate.h"

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
  _window.backgroundColor = [UIColor whiteColor];
  
  _viewController = [[UIViewController alloc] init];
  _viewController.view.backgroundColor = [UIColor blueColor]; // Retro test color
  
  [_window addSubview:_viewController.view];
  [_window makeKeyAndVisible];
  
  return YES;
}

- (void)dealloc {
  [_viewController release];
  [_window release];
  [super dealloc];
}

@end
