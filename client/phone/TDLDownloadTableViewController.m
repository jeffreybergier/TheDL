#import "TDLDownloadTableViewController.h"
#import "TDLDownloadList.h"
#import "TDLDownload.h"

@implementation TDLDownloadTableViewController

- (id)init {
  self = [super initWithStyle:UITableViewStylePlain];
  if (self) {
    [self setTitle:@"Load"];
    _downloads = [[NSArray alloc] init];
  }
  return self;
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

- (void)dealloc {
  [_downloads release];
  [super dealloc];
}

- (void)refreshDownloads {
  NSLog(@"[TDLDownloadTableViewController refreshDownloads] Start");
  [_downloads release];
  _downloads = [[TDLDownloadList allDownloads] retain];
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
  [[cell detailTextLabel] setText:[download contentType]];
  
  return cell;
}

@end
