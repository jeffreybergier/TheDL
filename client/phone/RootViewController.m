#import "RootViewController.h"
#import "DownloadsTableViewController.h"

@implementation RootViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self setTitle:@"The"];
  
  UIViewController *downViewController = [[UIViewController alloc] init];
  [downViewController setTitle:@"TheDL"];
  [[downViewController view] setBackgroundColor:[UIColor whiteColor]];
  
  UINavigationController *downNav = [[UINavigationController alloc] initWithRootViewController:downViewController];
  [[downNav tabBarItem] setTitle:@"Down"];
  
  DownloadsTableViewController *loadViewController = [[DownloadsTableViewController alloc] init];
  UINavigationController *loadNav = [[UINavigationController alloc] initWithRootViewController:loadViewController];
  [[loadNav tabBarItem] setTitle:@"Load"];
  
  [self setViewControllers:[NSArray arrayWithObjects:downNav, loadNav, nil]];
  
  [downViewController release];
  [downNav release];
  [loadViewController release];
  [loadNav release];
}

@end
