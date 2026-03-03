#import "RootViewController.h"
#import "TDLDownloadTableViewController.h"

@implementation RootViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self setTitle:@"The"];
  
  UIViewController *downViewController = [[UIViewController alloc] init];
  [downViewController setTitle:@"Down"];
  [[downViewController view] setBackgroundColor:[UIColor whiteColor]];
  [[downViewController tabBarItem] setTitle:@"Down"];
  
  TDLDownloadTableViewController *loadViewController = [[TDLDownloadTableViewController alloc] init];
  [[loadViewController tabBarItem] setTitle:@"Load"];
  
  [self setViewControllers:[NSArray arrayWithObjects:downViewController, loadViewController, nil]];
  
  [downViewController release];
  [loadViewController release];
}

@end
