#import <UIKit/UIKit.h>

@class TDLDownload;

/**
 * A table view controller that displays the list of downloaded files.
 */
@interface TDLDownloadTableViewController : UITableViewController <UIActionSheetDelegate> {
 @private
  NSArray *_downloads;
  TDLDownload *_selectedDownload;
}

/**
 * Refreshes the download list from disk.
 */
- (void)refreshDownloads;

@end
