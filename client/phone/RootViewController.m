#import "RootViewController.h"
#import "TDLDownloadTableViewController.h"
#import "TDLServiceListViewController.h"

@implementation RootViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  NSLog(@"[RootViewController viewDidLoad] Initializing tabs...");
  
  [self setTitle:@"The"];
  
  TDLServiceListViewController *serviceListVC = [[TDLServiceListViewController alloc] init];
  UINavigationController *downNav = [[UINavigationController alloc] initWithRootViewController:serviceListVC];
  [[downNav tabBarItem] setTitle:@"Down"];
  
  TDLDownloadTableViewController *downloadListVC = [[TDLDownloadTableViewController alloc] init];
  UINavigationController *loadNav = [[UINavigationController alloc] initWithRootViewController:downloadListVC];
  [[loadNav tabBarItem] setTitle:@"Load"];
  
  [self setViewControllers:[NSArray arrayWithObjects:downNav, loadNav, nil]];
  
  [serviceListVC release];
  [downNav release];
  [downloadListVC release];
  [loadNav release];
}

@end
