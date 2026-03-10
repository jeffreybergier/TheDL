#import "TDLDownloadInfoViewController.h"
#import "TDLDownload.h"
#import "TDLDownloadList.h"
#import "CrossPlatform.h"

@implementation TDLDownloadInfoViewController

- (id)initWithMetadata:(TDLDownload *)metadata 
               fileURL:(NSURL *)url 
          downloadList:(TDLDownloadList *)downloadList {
  self = [super initWithStyle:UITableViewStyleGrouped];
  if (self) {
    _metadata = [metadata retain];
    _fileURL = [url retain];
    _downloadList = [downloadList retain];
    [self setTitle:@"Download Info"];
    
    // Extract metadata for display
    _data = [[_metadata dictionaryRepresentation] retain];
    _keys = [[[_data allKeys] sortedArrayUsingSelector:@selector(compare:)] retain];
  }
  return self;
}

- (void)dealloc {
  [_metadata release];
  [_fileURL release];
  [_keys release];
  [_data release];
  [_downloadList release];
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
}

- (void)dismiss {
  [self dismissModalViewControllerAnimated:YES];
}

- (void)deleteAction {
  UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure?" 
                                                     delegate:(id<UIActionSheetDelegate>)self 
                                            cancelButtonTitle:@"Cancel" 
                                       destructiveButtonTitle:@"Delete File" 
                                            otherButtonTitles:nil];
  [sheet showInView:[self view]];
  [sheet release];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == [actionSheet destructiveButtonIndex]) {
    [_downloadList deleteFileAtURL:_fileURL];
    [self dismiss];
  }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0) return [_keys count];
  return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  if (section == 0) return @"Metadata";
  return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    static NSString *InfoCellID = @"InfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:InfoCellID];
    if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                     reuseIdentifier:InfoCellID] autorelease];
      [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    NSString *key = [_keys objectAtIndex:[indexPath row]];
    id value = [_data objectForKey:key];
    
    [[cell textLabel] setText:key];
    [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@", value]];
    
    return cell;
  } else {
    static NSString *DeleteCellID = @"DeleteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DeleteCellID];
    if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                     reuseIdentifier:DeleteCellID] autorelease];
      [[cell textLabel] setTextColor:[UIColor redColor]];
      [[cell textLabel] setTextAlignment:XPTextAlignmentCenter];
    }

    [[cell textLabel] setText:@"Delete File"];
    return cell;
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  if (indexPath.section == 1) {
    [self deleteAction];
  }
}

@end
