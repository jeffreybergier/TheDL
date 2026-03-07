#import "TDLCURLRequestServiceTableViewController.h"
#import "TDLCURLRequestService.h"
#import "TDLDownload.h"

@implementation TDLCURLRequestServiceTableViewController

- (id)initWithService:(TDLCURLRequestService *)service {
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
  UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Debug CURL Downloads"
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:@"Image (Google Logo)", @"Video (Sample)", nil];
  [sheet showInView:[self view]];
  [sheet release];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
  NSString *urlStr = nil;
  
  if ([title isEqualToString:@"Image (Google Logo)"]) {
    urlStr = @"https://www.google.com/images/branding/googlelogo/1x/googlelogo_white_background_color_272x92dp.png";
  } else if ([title isEqualToString:@"Video (Sample)"]) {
    urlStr = @"http://rss-the-planet.saturdayapps.workers.dev/proxy/aHR0cHMlM0ElMkYlMkZ3c2IuaG9zdGRvbi5uZS5qcCUyRnNnbTIzNCUyRmNhY2hlJTJGbWVkaWFfYXR0YWNobWVudHMlMkZmaWxlcyUyRjExNiUyRjE3OSUyRjkyMCUyRjEyMCUyRjAyNyUyRjA3MyUyRm9yaWdpbmFsJTJGODQ4NDAzMThkNGIzNTlhMi5tcDQ%3D/318d4b359a2.mp4?key=vXnQzLwR&option=asset";
  }
  
  if (urlStr) {
    NSLog(@"[TDLCURLRequestServiceTableViewController] Fetching debug URL: %@", urlStr);
    [_service fetchURL:[NSURL URLWithString:urlStr]];
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
  return @"Add CURL Download";
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
