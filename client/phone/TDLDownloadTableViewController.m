#import "TDLDownloadTableViewController.h"
#import "TDLDownloadList.h"
#import "TDLDownload.h"
#import "TDLImageViewController.h"
#import <MediaPlayer/MediaPlayer.h>

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
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [_downloads release];
  [_selectedDownload release];
  [_moviePlayer release];
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  NSLog(@"[TDLDownloadTableViewController viewDidLoad]");
  
  UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] 
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                    target:self 
                                    action:@selector(refreshDownloads)];
  
  UIBarButtonItem *debugButton = [[UIBarButtonItem alloc] 
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                   target:self 
                                   action:@selector(createDebugData)];
  
  [[self navigationItem] setRightBarButtonItem:refreshButton];
  [[self navigationItem] setLeftBarButtonItem:debugButton];
  
  [refreshButton release];
  [debugButton release];
  
  [self refreshDownloads];
}

- (void)createDebugData {
  NSLog(@"[TDLDownloadTableViewController createDebugData] Creating fake data...");
  [TDLDownloadList __DEBUG_createFakeData];
  [self refreshDownloads];
}

- (void)refreshDownloads {
  NSLog(@"[TDLDownloadTableViewController refreshDownloads] Start");
  [[TDLDownloadList sharedList] loadDownloadsFromDisk];
  [_downloads release];
  _downloads = [[[TDLDownloadList sharedList] allDownloads] retain];
  NSLog(@"[TDLDownloadTableViewController refreshDownloads] Loaded %lu downloads", (unsigned long)[_downloads count]);
  [[self tableView] reloadData];
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
  }
  
  TDLDownload *download = [_downloads objectAtIndex:[indexPath row]];
  [[cell textLabel] setText:[download displayName]];
  
  NSString *status = @"Unknown";
  switch ([download state]) {
    case TDLDownloadStatePending: status = @"Pending"; break;
    case TDLDownloadStateDownloading: status = @"Downloading..."; break;
    case TDLDownloadStateFinished: status = @"Finished"; break;
    case TDLDownloadStateFailed: status = @"Failed"; break;
  }
  [[cell detailTextLabel] setText:status];
  
  return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  [_selectedDownload release];
  _selectedDownload = [[_downloads objectAtIndex:[indexPath row]] retain];
  
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Download Actions"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:@"Button 1", @"Button 2", nil];
  
  if ([[_selectedDownload contentType] hasPrefix:@"image/"]) {
    [actionSheet addButtonWithTitle:@"View Image"];
  }
  
  if ([[_selectedDownload contentType] hasPrefix:@"video/"]) {
    [actionSheet addButtonWithTitle:@"Play"];
  }
  
  [actionSheet showInView:[self view]];
  [actionSheet release];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
  NSLog(@"[TDLDownloadTableViewController actionSheet:clickedButtonAtIndex:] title: %@, index: %ld", 
        title, (long)buttonIndex);
  
  if ([title isEqualToString:@"View Image"]) {
    TDLImageViewController *imageVC = [[TDLImageViewController alloc] initWithDownload:_selectedDownload];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:imageVC];
    [self presentModalViewController:nav animated:YES];
    [imageVC release];
    [nav release];
  } else if ([title isEqualToString:@"Play"]) {
    NSURL *url = [NSURL fileURLWithPath:[_selectedDownload filePath]];
    
    if (_moviePlayer) {
      [_moviePlayer release];
      _moviePlayer = nil;
    }
    
    _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(moviePlayBackDidFinish:) 
                                                 name:MPMoviePlayerPlaybackDidFinishNotification 
                                               object:_moviePlayer];
    
    // In iOS 3.1, this plays full screen and manages its own window.
    [_moviePlayer play];
  }
}

- (void)moviePlayBackDidFinish:(NSNotification *)notification {
  NSLog(@"[TDLDownloadTableViewController moviePlayBackDidFinish:]");
  [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                  name:MPMoviePlayerPlaybackDidFinishNotification 
                                                object:_moviePlayer];
  
  if (_moviePlayer) {
    [_moviePlayer stop];
    [_moviePlayer release];
    _moviePlayer = nil;
  }
}

@end
