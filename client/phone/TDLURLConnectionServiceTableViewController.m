#import "TDLURLConnectionServiceTableViewController.h"
#import "TDLURLConnectionService.h"
#import "TDLDownload.h"
#import "CrossPlatform.h"

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
  
  // Using UITextView for multiline wrapping
  _urlField = (UITextField *)[[UITextView alloc] initWithFrame:CGRectMake(10, 5, 280, 74)];
  [(UITextView *)_urlField setBackgroundColor:[UIColor clearColor]];
  [(UITextView *)_urlField setFont:[UIFont systemFontOfSize:14.0]];
  [(UITextView *)_urlField setDelegate:(id<UITextViewDelegate>)self];
  [(UITextView *)_urlField setReturnKeyType:UIReturnKeyDone];
  [(UITextView *)_urlField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
  [(UITextView *)_urlField setAutocorrectionType:UITextAutocorrectionTypeNo];
}

- (void)fetchAction {
  NSString *urlString = [(UITextView *)_urlField text];
  if ([urlString length] > 0) {
    NSURL *url = [NSURL URLWithString:urlString];
    if (url) {
      [_service fetchURL:url];
      [(UITextView *)_urlField setText:@""];
      // Refresh the button state
      [self textViewDidChange:(UITextView *)_urlField];
    }
  }
  [_urlField resignFirstResponder];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
  // Reload only the button row to update enabled state
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
  [[self tableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                          withRowAnimation:UITableViewRowAnimationNone];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
  if ([text isEqualToString:@"\n"]) {
    [self fetchAction];
    return NO;
  }
  return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0) return 2; // Row 0: TextView, Row 1: Download Button
  return [[[TDLService sampleURLs] allKeys] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  if (section == 0) return @"Add Download";
  return @"Sample URLs";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0 && indexPath.row == 0) return 84.0;
  return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    if (indexPath.row == 0) {
      static NSString *InputCellID = @"InputCell";
      UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:InputCellID];
      if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:InputCellID] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
      }
      
      if ([_urlField superview] != [cell contentView]) {
        [_urlField removeFromSuperview];
        [[cell contentView] addSubview:_urlField];
      }
      return cell;
    } else {
      static NSString *ButtonCellID = @"ButtonCell";
      UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ButtonCellID];
      if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:ButtonCellID] autorelease];
        [[cell textLabel] setTextAlignment:XPTextAlignmentCenter];
      }
      
      [[cell textLabel] setText:@"Download"];
      
      BOOL hasText = [[(UITextView *)_urlField text] length] > 0;
      if (hasText) {
        [[cell textLabel] setTextColor:[UIColor blueColor]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
      } else {
        [[cell textLabel] setTextColor:[UIColor grayColor]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
      }
      
      return cell;
    }
  } else {
    static NSString *SampleCellID = @"SampleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SampleCellID];
    if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                     reuseIdentifier:SampleCellID] autorelease];
    }
    
    NSDictionary *samples = [TDLService sampleURLs];
    NSArray *sortedKeys = [[samples allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSString *name = [sortedKeys objectAtIndex:indexPath.row];
    [[cell textLabel] setText:name];
    
    return cell;
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  if (indexPath.section == 0 && indexPath.row == 1) {
    if ([[(UITextView *)_urlField text] length] > 0) {
      [self fetchAction];
    }
  } else if (indexPath.section == 1) {
    NSDictionary *samples = [TDLService sampleURLs];
    NSArray *sortedKeys = [[samples allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSString *name = [sortedKeys objectAtIndex:indexPath.row];
    NSString *urlStr = [samples objectForKey:name];
    
    [(UITextView *)_urlField setText:urlStr];
    // Refresh the button state
    [self textViewDidChange:(UITextView *)_urlField];
  }
}

@end
