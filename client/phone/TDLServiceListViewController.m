#import "TDLServiceListViewController.h"
#import "TDLServiceManager.h"
#import "TDLService.h"
#import "TDLURLConnectionServiceTableViewController.h"
#import "TDLCURLRequestServiceTableViewController.h"
#import "TDLURLConnectionService.h"
#import "TDLCURLRequestService.h"

@implementation TDLServiceListViewController

- (id)init {
  self = [super initWithStyle:UITableViewStyleGrouped];
  if (self) {
    [self setTitle:@"Services"];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] 
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                  target:self 
                                  action:@selector(dismiss)];
  [[self navigationItem] setLeftBarButtonItem:doneButton];
  [doneButton release];
}

- (void)dismiss {
  [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [[[TDLServiceManager sharedManager] availableServices] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"ServiceCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                   reuseIdentifier:CellIdentifier] autorelease];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
  }
  
  TDLService *service = [[[TDLServiceManager sharedManager] availableServices] objectAtIndex:[indexPath row]];
  [[cell textLabel] setText:[service serviceName]];
  
  return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  TDLService *service = [[[TDLServiceManager sharedManager] availableServices] objectAtIndex:[indexPath row]];
  
  if ([[service serviceIdentifier] isEqualToString:@"com.kumasan.thedl.service.urlconnection"]) {
    TDLURLConnectionServiceTableViewController *vc = [[TDLURLConnectionServiceTableViewController alloc] initWithService:(TDLURLConnectionService *)service];
    [[self navigationController] pushViewController:vc animated:YES];
    [vc release];
  } else if ([[service serviceIdentifier] isEqualToString:@"com.kumasan.thedl.service.curl"]) {
    TDLCURLRequestServiceTableViewController *vc = [[TDLCURLRequestServiceTableViewController alloc] initWithService:(TDLCURLRequestService *)service];
    [[self navigationController] pushViewController:vc animated:YES];
    [vc release];
  }
}

@end
