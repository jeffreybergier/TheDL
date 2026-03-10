#import "TDLDownloadTableViewController.h"
#import "TDLDownloadList.h"
#import "TDLDownload.h"
#import "TDLImageViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "TDLDownloadInfoViewController.h"
#import "TDLTextViewController.h"
#import "TDLServiceListViewController.h"
#import "TDLServiceManager.h"

@implementation TDLDownloadTableViewController

- (id)initWithDownloadList:(TDLDownloadList *)downloadList 
            serviceManager:(TDLServiceManager *)serviceManager {
  self = [super initWithStyle:UITableViewStylePlain];
  if (self) {
    [self setTitle:@"TheDL"];
    _downloads = [[NSArray alloc] init];
    _downloadList = [downloadList retain];
    _serviceManager = [serviceManager retain];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(handleDownloadUpdated:) 
                                                 name:TDLDownloadListUpdatedNotification 
                                               object:nil];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [_downloads release];
  [_selectedDownload release];
  [_downloadList release];
  [_serviceManager release];
  [super dealloc];
}

- (void)handleDownloadUpdated:(NSNotification *)notification {
  NSURL *url = [[notification userInfo] objectForKey:@"URL"];
  if (!url) return;
  
  NSLog(@"[TDLDownloadTableViewController] handleDownloadUpdated: received for %@", [url path]);
  
  // Find index of this URL in our data source
  NSUInteger index = [_downloads indexOfObject:url];
  if (index != NSNotFound) {
    NSLog(@"[TDLDownloadTableViewController] Found URL at index %lu, reloading row", (unsigned long)index);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    [[self tableView] reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
  } else {
    NSLog(@"[TDLDownloadTableViewController] URL not found in _downloads list, refreshing full list");
    // If not found, it might be a NEW download, so refresh the full list
    [self refreshDownloads];
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  NSLog(@"[TDLDownloadTableViewController viewDidLoad]");

  UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
      initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                           target:self
                           action:@selector(addDownload)];
  [[self navigationItem] setRightBarButtonItem:addButton];
  [addButton release];

  [self refreshDownloads];
}

- (void)refreshDownloads {
  NSLog(@"[TDLDownloadTableViewController refreshDownloads] Start");
  [_downloads release];
  _downloads = [[_downloadList allDownloads] retain];
  NSLog(@"[TDLDownloadTableViewController refreshDownloads] Found %lu files", (unsigned long)[_downloads count]);
  [[self tableView] reloadData];
}

- (void)addDownload {
  TDLServiceListViewController *serviceVC = [[TDLServiceListViewController alloc] initWithServiceManager:_serviceManager];
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:serviceVC];
  [self presentModalViewController:nav animated:YES];
  [serviceVC release];
  [nav release];
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [_downloads count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"DownloadCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                   reuseIdentifier:CellIdentifier] autorelease];
    [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
  }

  NSURL *fileURL = [_downloads objectAtIndex:[indexPath row]];
  TDLDownload *metadata = [_downloadList getTDLDownloadForURL:fileURL];
  
  [[cell textLabel] setText:[fileURL lastPathComponent]];
  
  NSNumber *fileSizeNumber = nil;
  [fileURL getResourceValue:&fileSizeNumber forKey:NSURLFileSizeKey error:nil];
  long long currentSize = [fileSizeNumber longLongValue];
  long kb = (long)(currentSize / 1024);
  
  NSString *type = [metadata contentType] ? [metadata contentType] : @"unknown";
  
  // Extract last component of reverse-dns service identifier
  NSString *service = [[[metadata serviceIdentifier] componentsSeparatedByString:@"."] lastObject];
  if (!service) service = @"none";

  NSString *detail;
  if ([metadata state] == TDLDownloadStateDownloading) {
    if ([metadata contentSize] > 0) {
      int percent = (int)((currentSize * 100) / [metadata contentSize]);
      if (percent > 100) percent = 100;
      detail = [NSString stringWithFormat:@"⇣ %d%%", percent];
    } else {
      detail = [NSString stringWithFormat:@"⇣ %ld KB", kb];
    }
  } else if ([metadata errorMessage]) {
    detail = [NSString stringWithFormat:@"⚠️ %@", [metadata errorMessage]];
  } else {
    detail = [NSString stringWithFormat:@"%ld KB・%@・%@", kb, type, service];
  }
  [[cell detailTextLabel] setText:detail];
  return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSURL *fileURL = [_downloads objectAtIndex:[indexPath row]];
  [self openDownloadWithURL:fileURL];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
  NSURL *fileURL = [_downloads objectAtIndex:[indexPath row]];
  TDLDownload *metadata = [_downloadList getTDLDownloadForURL:fileURL];
  
  TDLDownloadInfoViewController *infoVC = [[TDLDownloadInfoViewController alloc] initWithMetadata:metadata 
                                                                                         fileURL:fileURL 
                                                                                    downloadList:_downloadList];
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:infoVC];
  [self presentModalViewController:nav animated:YES];
  [infoVC release];
  [nav release];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    NSURL *fileURL = [_downloads objectAtIndex:[indexPath row]];
    [_downloadList deleteFileAtURL:fileURL];
    [self refreshDownloads];
  }
}

- (void)openDownloadWithURL:(NSURL *)fileURL {
  TDLDownload *metadata = [_downloadList getTDLDownloadForURL:fileURL];
  NSString *contentType = [metadata contentType];

  if ([contentType hasPrefix:@"image/"]) {
    TDLImageViewController *imageVC = [[TDLImageViewController alloc] initWithDownloadURL:fileURL];
    [[self navigationController] pushViewController:imageVC animated:YES];
    [imageVC release];
  } else if ([contentType hasPrefix:@"video/"] || [contentType hasPrefix:@"audio/"]) {
    MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:fileURL];
    [self presentMoviePlayerViewControllerAnimated:player];
    [player release];
  } else if ([contentType isEqualToString:@"text/plain"] || [contentType isEqualToString:@"text/markdown"]) {
    TDLTextViewController *textVC = [[TDLTextViewController alloc] initWithDownloadURL:fileURL];
    [[self navigationController] pushViewController:textVC animated:YES];
    [textVC release];
  } else {
    TDLDownloadInfoViewController *infoVC = [[TDLDownloadInfoViewController alloc] initWithMetadata:metadata 
                                                                                           fileURL:fileURL 
                                                                                      downloadList:_downloadList];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:infoVC];
    [self presentModalViewController:nav animated:YES];
    [infoVC release];
    [nav release];
  }
}

@end
