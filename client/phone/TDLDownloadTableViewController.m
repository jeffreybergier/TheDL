#import "TDLDownloadTableViewController.h"
#import "TDLDownloadList.h"
#import "TDLDownload.h"
#import "TDLImageViewController.h"
#import "TDLPlayerViewController.h"
#import "TDLDownloadInfoViewController.h"
#import "TDLTextViewController.h"
#import "CrossPlatform.h"

@implementation TDLDownloadTableViewController

- (id)init {
  self = [super initWithStyle:UITableViewStylePlain];
  if (self) {
    [self setTitle:@"Load"];
    _downloads = [[NSArray alloc] init];
  }
  return self;
}

- (void)dealloc {
  [_downloads release];
  [_selectedDownload release];
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  NSLog(@"[TDLDownloadTableViewController viewDidLoad]");

  UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                    target:self
                                    action:@selector(refreshDownloads)];

  [[self navigationItem] setRightBarButtonItem:refreshButton];

  [refreshButton release];

  [self refreshDownloads];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  // [self refreshDownloads];
}

- (void)refreshDownloads {
  NSLog(@"[TDLDownloadTableViewController refreshDownloads] Start");
  [[TDLDownloadList sharedList] loadDownloadsFromDisk];
  [_downloads release];
  _downloads = [[[TDLDownloadList sharedList] allDownloads] retain];
  NSLog(@"[TDLDownloadTableViewController refreshDownloads] Loaded %lu downloads", (unsigned long)[_downloads count]);
  [[self tableView] reloadData];
}

- (void)openDownload:(TDLDownload *)download {
  if (!download) return;
  
  NSString *contentType = [download contentType];
  if ([contentType hasPrefix:@"image/"]) {
    TDLImageViewController *imageVC = [[TDLImageViewController alloc] initWithDownload:download];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:imageVC];
    [self presentModalViewController:nav animated:YES];
    [imageVC release];
    [nav release];
  } else if ([contentType hasPrefix:@"video/"]) {
    NSURL *url = [NSURL fileURLWithPath:[download filePath]];
    TDLPlayerViewController *playerVC = [[TDLPlayerViewController alloc] initWithContentURL:url];
    [self presentModalViewController:playerVC animated:YES];
    [playerVC play];
    [playerVC release];
  } else if ([contentType hasPrefix:@"text/"] || [contentType containsString:@"xml"] || [contentType containsString:@"json"]) {
    TDLTextViewController *textVC = [[TDLTextViewController alloc] initWithDownload:download];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:textVC];
    [self presentModalViewController:nav animated:YES];
    [textVC release];
    [nav release];
  } else {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Open" 
                                                    message:@"This file type is not supported for viewing yet." 
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
  }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [_downloads count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"DownloadCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                   reuseIdentifier:CellIdentifier] autorelease];
    [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
  }
  
  TDLDownload *download = [_downloads objectAtIndex:[indexPath row]];
  [[cell textLabel] setText:[download displayName]];
  
  long kb = (long)([download actualSize] / 1024);
  NSString *type = [download contentType] ? [download contentType] : @"unknown";
  
  NSString *detail = [NSString stringWithFormat:@"%ld KB | %@", kb, type];
  [[cell detailTextLabel] setText:detail];
  
  return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    TDLDownload *download = [_downloads objectAtIndex:[indexPath row]];
    [[TDLDownloadList sharedList] deleteDownload:download];
    [self refreshDownloads];
  }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  TDLDownload *download = [_downloads objectAtIndex:[indexPath row]];
  [self openDownload:download];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
  TDLDownload *download = [_downloads objectAtIndex:[indexPath row]];
  TDLDownloadInfoViewController *infoVC = [[TDLDownloadInfoViewController alloc] initWithDownload:download];
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:infoVC];
  [self presentModalViewController:nav animated:YES];
  [infoVC release];
  [nav release];
}

@end
