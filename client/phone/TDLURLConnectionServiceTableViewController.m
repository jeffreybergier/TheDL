#import "TDLURLConnectionServiceTableViewController.h"
#import "TDLURLConnectionService.h"
#import "TDLDownloadTask.h"

@implementation TDLURLConnectionServiceTableViewController

- (id)initWithService:(TDLURLConnectionService *)service {
  self = [super initWithStyle:UITableViewStyleGrouped];
  if (self) {
    _service = [service retain];
    [self setTitle:[_service serviceName]];
  }
  return self;
}

- (void)dealloc {
  [_service release];
  [_urlField setDelegate:nil];
  [_urlField release];
  [_refreshTimer invalidate];
  [_refreshTimer release];
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  _urlField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 280, 24)];
  [_urlField setBorderStyle:UITextBorderStyleNone];
  [_urlField setPlaceholder:@"http://example.com/file"];
  [_urlField setDelegate:self];
  [_urlField setReturnKeyType:UIReturnKeyDone];
  [_urlField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
  [_urlField setAutocorrectionType:UITextAutocorrectionTypeNo];
  
  _refreshTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0 
                                                   target:self 
                                                 selector:@selector(refreshAction) 
                                                 userInfo:nil 
                                                  repeats:YES] retain];
}

- (void)refreshAction {
  [[self tableView] reloadData];
}

- (void)fetchAction {
  NSString *urlString = [_urlField text];
  if ([urlString length] > 0) {
    NSURL *url = [NSURL URLWithString:urlString];
    if (url) {
      [_service fetchURL:url];
      [_urlField setText:@""];
    }
  }
  [_urlField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self fetchAction];
  return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0) {
    return 1;
  }
  return [[_service activeTasks] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    return @"Add Download";
  }
  return @"In Progress";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([indexPath section] == 0) {
    static NSString *InputCellID = @"InputCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:InputCellID];
    if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                     reuseIdentifier:InputCellID] autorelease];
      [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
      [[cell contentView] addSubview:_urlField];
    }
    return cell;
  }
  
  static NSString *TaskCellID = @"TaskCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TaskCellID];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                   reuseIdentifier:TaskCellID] autorelease];
  }
  
  NSArray *tasks = [_service activeTasks];
  TDLDownloadTask *task = [tasks objectAtIndex:([tasks count] - 1 - [indexPath row])];
  
  [[cell textLabel] setText:[[task url] absoluteString]];
  
  NSString *status = @"Unknown";
  switch ([task state]) {
    case TDLDownloadTaskStateRunning:
      status = [NSString stringWithFormat:@"Downloading (%lu bytes)...", 
                (unsigned long)[[task accumulatedData] length]];
      break;
    case TDLDownloadTaskStateFinished:
      status = @"Finished";
      break;
    case TDLDownloadTaskStateFailed:
      status = [NSString stringWithFormat:@"Failed: %@", [task errorMessage]];
      break;
  }
  [[cell detailTextLabel] setText:status];
  
  return cell;
}

@end
