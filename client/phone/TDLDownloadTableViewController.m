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
  
  UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] 
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
                                    target:self 
                                    action:@selector(refreshDownloads)];
  [[self navigationItem] setRightBarButtonItem:refreshButton];
  [refreshButton release];
  
  [self refreshDownloads];
}

- (void)dealloc {
  [_downloads release];
  [super dealloc];
}

- (void)refreshDownloads {
  [_downloads release];
  _downloads = [[TDLDownloadList allDownloads] retain];
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
  [[cell textLabel] setText:[download filename]];
  [[cell detailTextLabel] setText:[download contentType]];
  
  return cell;
}

@end
