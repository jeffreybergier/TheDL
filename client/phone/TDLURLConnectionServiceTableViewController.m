#import "TDLURLConnectionServiceTableViewController.h"
#import "TDLURLConnectionService.h"
#import "TDLDownload.h"

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
  
  UIBarButtonItem *debugButton = [[UIBarButtonItem alloc] 
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                   target:self 
                                   action:@selector(triggerDebugDownload)];
  [[self navigationItem] setRightBarButtonItem:debugButton];
  [debugButton release];
}

- (void)triggerDebugDownload {
  NSLog(@"[TDLURLConnectionServiceTableViewController triggerDebugDownload] Starting debug fetch for Google logo...");
  
  NSString *urlStr = @"https://www.google.com/images/branding/googlelogo/1x/googlelogo_white_background_color_272x92dp.png";
  NSURL *url = [NSURL URLWithString:urlStr];
  if (url) {
    [_service fetchURL:url];
  }
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
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return @"Add Download";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *InputCellID = @"InputCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:InputCellID];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                   reuseIdentifier:InputCellID] autorelease];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
  }
  
  // Ensure _urlField is in the current cell (handle reuse)
  if ([_urlField superview] != [cell contentView]) {
    [_urlField removeFromSuperview];
    [[cell contentView] addSubview:_urlField];
  }
  return cell;
}

@end
