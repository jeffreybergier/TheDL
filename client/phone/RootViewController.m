#import "RootViewController.h"

@implementation RootViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self setTitle:@"The"];
  
  UIViewController *downViewController = [[UIViewController alloc] init];
  [[downViewController view] setBackgroundColor:[UIColor whiteColor]];
  [[downViewController tabBarItem] setTitle:@"Down"];
  
  UIViewController *loadViewController = [[UIViewController alloc] init];
  [[loadViewController view] setBackgroundColor:[UIColor lightGrayColor]];
  [[loadViewController tabBarItem] setTitle:@"Load"];
  
  [self setViewControllers:[NSArray arrayWithObjects:downViewController, loadViewController, nil]];
  
  [downViewController release];
  [loadViewController release];
}

@end
