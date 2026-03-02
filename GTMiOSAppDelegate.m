#import "GTMiOSAppDelegate.h"

@implementation GTMiOSAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application 
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  NSLog(@"[GTMiOSAppDelegate application:didFinishLaunchingWithOptions:] Started TheDL on iOS.");
  
  _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  _window.backgroundColor = [UIColor whiteColor];
  
  UIViewController *rootVC = [[UIViewController alloc] init];
  rootVC.view.backgroundColor = [UIColor blueColor]; // Retro test color
  
  [_window setRootViewController:rootVC];
  [_window makeKeyAndVisible];
  
  [rootVC release];
  return YES;
}

- (void)dealloc {
  [_window release];
  [super dealloc];
}

@end
