#import "TDLDownloadTableViewController.h"
#import "TDLDownloadList.h"
#import "TDLDownload.h"
#import "TDLImageViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "TDLDownloadInfoViewController.h"
#import "TDLTextViewController.h"
#import "TDLServiceListViewController.h"
#import "CrossPlatform.h"

@implementation TDLDownloadTableViewController

- (id)init {
  self = [super initWithStyle:UITableViewStylePlain];
  if (self) {
    [self setTitle:@"TheDL"];
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

  UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                 initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                 target:self
                                 action:@selector(addDownload)];
  [[self navigationItem] setRightBarButtonItem:addButton];
  [addButton release];

  UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                    target:self
                                    action:@selector(refreshDownloads)];
  [[self navigationItem] setLeftBarButtonItem:refreshButton];
  [refreshButton release];

  [self refreshDownloads];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self refreshDownloads];
}

- (void)addDownload {
  TDLServiceListViewController *serviceListVC = [[TDLServiceListViewController alloc] init];
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:serviceListVC];
  [self presentModalViewController:nav animated:YES];
  [serviceListVC release];
  [nav release];
}

- (void)refreshDownloads {
  NSLog(@"[TDLDownloadTableViewController refreshDownloads] Start");
  [_downloads release];
  _downloads = [[[TDLDownloadList sharedList] allDownloads] retain];
  NSLog(@"[TDLDownloadTableViewController refreshDownloads] Found %lu files", (unsigned long)[_downloads count]);
  [[self tableView] reloadData];
}

- (void)openDownloadWithURL:(NSURL *)fileURL {
  if (!fileURL) return;
  
  TDLDownload *metadata = [[TDLDownloadList sharedList] getTDLDownloadForURL:fileURL];
  
  // Prevent opening if there's an error
  if ([metadata errorMessage]) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Download Error" 
                                                    message:[metadata errorMessage]
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
    return;
  }
  
  NSString *contentType = [metadata contentType];
  
  if ([contentType hasPrefix:@"image/"]) {
    TDLImageViewController *imageVC = [[TDLImageViewController alloc] initWithDownloadURL:fileURL];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:imageVC];
    [self presentModalViewController:nav animated:YES];
    [imageVC release];
    [nav release];
  } else if ([contentType hasPrefix:@"video/"]) {
    // Standard system video player - no subclass needed!
    MPMoviePlayerViewController *playerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:fileURL];
    [[playerVC moviePlayer] setScalingMode:MPMovieScalingModeAspectFit];
    [self presentMoviePlayerViewControllerAnimated:playerVC];
    [playerVC release];
  } else if ([contentType hasPrefix:@"text/"] || 
             [contentType rangeOfString:@"xml"].location != NSNotFound || 
             [contentType rangeOfString:@"json"].location != NSNotFound) {
    TDLTextViewController *textVC = [[TDLTextViewController alloc] initWithDownloadURL:fileURL];

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:textVC];
    [self presentModalViewController:nav animated:YES];
    [textVC release];
    [nav release];
  } else {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Open" 
                                                    message:[NSString stringWithFormat:@"File type '%@' is not supported.", contentType ? contentType : @"unknown"]
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
  
  NSURL *fileURL = [_downloads objectAtIndex:[indexPath row]];
  TDLDownload *metadata = [[TDLDownloadList sharedList] getTDLDownloadForURL:fileURL];
  
  [[cell textLabel] setText:[fileURL lastPathComponent]];
  
  NSNumber *fileSizeNumber = nil;
  [fileURL getResourceValue:&fileSizeNumber forKey:NSURLFileSizeKey error:nil];
  long kb = (long)([fileSizeNumber longLongValue] / 1024);
  
  NSString *type = [metadata contentType] ? [metadata contentType] : @"unknown";
  
  // Extract last component of reverse-dns service identifier
  NSString *service = [[[metadata serviceIdentifier] componentsSeparatedByString:@"."] lastObject];
  if (!service) service = @"none";

  NSString *detail;
  if ([metadata errorMessage]) {
    detail = [NSString stringWithFormat:@"⚠️ %@", [metadata errorMessage]];
  } else {
    detail = [NSString stringWithFormat:@"%ld KB・%@・%@", kb, type, service];
  }
  [[cell detailTextLabel] setText:detail];
  return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    NSURL *fileURL = [_downloads objectAtIndex:[indexPath row]];
    [[TDLDownloadList sharedList] deleteFileAtURL:fileURL];
    [self refreshDownloads];
  }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  NSURL *fileURL = [_downloads objectAtIndex:[indexPath row]];
  [self openDownloadWithURL:fileURL];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
  NSURL *fileURL = [_downloads objectAtIndex:[indexPath row]];
  TDLDownload *metadata = [[TDLDownloadList sharedList] getTDLDownloadForURL:fileURL];
  
  TDLDownloadInfoViewController *infoVC = [[TDLDownloadInfoViewController alloc] initWithMetadata:metadata fileURL:fileURL];
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:infoVC];
  [self presentModalViewController:nav animated:YES];
  [infoVC release];
  [nav release];
}

@end
