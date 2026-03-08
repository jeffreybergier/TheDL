#import "TDLServiceListViewController.h"
#import "TDLServiceManager.h"
#import "TDLService.h"
#import "CrossPlatform.h"

@implementation TDLServiceListViewController

- (id)init {
  self = [super initWithStyle:UITableViewStyleGrouped];
  if (self) {
    [self setTitle:@"Download"];
    _selectedServiceIndex = 0;
    
    // Setup sorted sample keys
    NSDictionary *samples = [TDLService sampleURLs];
    _sampleKeys = [[[samples allKeys] sortedArrayUsingSelector:@selector(compare:)] retain];
  }
  return self;
}

- (void)dealloc {
  [_urlTextView release];
  [_sampleKeys release];
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] 
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                    target:self 
                                    action:@selector(dismiss)];
  [[self navigationItem] setRightBarButtonItem:doneButton];
  [doneButton release];

  // Setup the URL Text View
  _urlTextView = [[UITextView alloc] initWithFrame:CGRectMake(4, 4, 280, 96)];
  [_urlTextView setFont:[UIFont systemFontOfSize:14]];
  [_urlTextView setKeyboardType:UIKeyboardTypeURL];
  [_urlTextView setAutocapitalizationType:UITextAutocapitalizationTypeNone];
  [_urlTextView setAutocorrectionType:UITextAutocorrectionTypeNo];
  [_urlTextView setDelegate:self];

  // Tap Gesture to dismiss keyboard when tapping outside
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:_urlTextView 
                                                                        action:@selector(resignFirstResponder)];
  [tap setCancelsTouchesInView:NO];
  [[self tableView] addGestureRecognizer:tap];
  [tap release];
}

- (void)dismiss {
  [self dismissModalViewControllerAnimated:YES];
}

- (void)startDownload {
  NSString *urlText = [_urlTextView text];
  urlText = [urlText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  if ([urlText length] == 0) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                    message:@"Please enter a URL." 
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
    return;
  }

  NSURL *url = [NSURL URLWithString:urlText];
  if (!url) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                    message:@"Invalid URL." 
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
    return;
  }

  NSArray *services = [[TDLServiceManager sharedManager] availableServices];
  if (_selectedServiceIndex < [services count]) {
    TDLService *service = [services objectAtIndex:_selectedServiceIndex];
    [service fetchURL:url];
    [self dismiss];
  }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  [_urlTextView resignFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0) return 2; // URL and Start Download
  if (section == 1) return [[[TDLServiceManager sharedManager] availableServices] count]; // Services
  if (section == 2) return [_sampleKeys count]; // Examples
  return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  if (section == 0) return @"Download URL";
  if (section == 1) return @"Download Service";
  if (section == 2) return @"Example URL";
  return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([indexPath section] == 0 && [indexPath row] == 0) {
    return 104.0;
  }
  return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([indexPath section] == 0) {
    if ([indexPath row] == 0) {
      static NSString *UrlCellID = @"UrlCell";
      UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UrlCellID];
      if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:UrlCellID] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
      }
      
      CGRect frame = [cell contentView].bounds;
      frame.origin.x = 4;
      frame.size.width -= 8;
      frame.origin.y = 4;
      frame.size.height = 96.0;
      [_urlTextView setFrame:frame];
      [[cell contentView] addSubview:_urlTextView];
      return cell;
    } else {
      static NSString *ActionCellID = @"ActionCell";
      UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ActionCellID];
      if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:ActionCellID] autorelease];
        [[cell textLabel] setTextAlignment:XPTextAlignmentCenter];
        [[cell textLabel] setTextColor:[UIColor colorWithRed:0.0 green:0.35 blue:0.91 alpha:1.0]];
      }
      [[cell textLabel] setText:@"Start Download"];
      return cell;
    }
  }
  
  if ([indexPath section] == 1) {
    static NSString *ServiceCellID = @"ServiceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ServiceCellID];
    if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                     reuseIdentifier:ServiceCellID] autorelease];
    }
    
    TDLService *service = [[[TDLServiceManager sharedManager] availableServices] objectAtIndex:[indexPath row]];
    [[cell textLabel] setText:[service serviceName]];
    
    if ([indexPath row] == _selectedServiceIndex) {
      [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
      [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    return cell;
  }

  if ([indexPath section] == 2) {
    static NSString *SampleCellID = @"SampleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SampleCellID];
    if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                     reuseIdentifier:SampleCellID] autorelease];
    }
    
    NSString *key = [_sampleKeys objectAtIndex:[indexPath row]];
    NSString *url = [[TDLService sampleURLs] objectForKey:key];
    
    [[cell textLabel] setText:key];
    [[cell detailTextLabel] setText:url];
    return cell;
  }
  
  return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  if ([indexPath section] == 0 && [indexPath row] == 1) {
    [self startDownload];
  } else if ([indexPath section] == 1) {
    _selectedServiceIndex = [indexPath row];
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
  } else if ([indexPath section] == 2) {
    NSString *key = [_sampleKeys objectAtIndex:[indexPath row]];
    NSString *url = [[TDLService sampleURLs] objectForKey:key];
    [_urlTextView setText:url];
    [_urlTextView resignFirstResponder];
    // Scroll back to top to see the filled URL
    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] 
                     atScrollPosition:UITableViewScrollPositionTop 
                             animated:YES];
  }
}

@end
