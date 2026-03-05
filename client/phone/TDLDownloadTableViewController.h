#import <UIKit/UIKit.h>

/**
 * A table view controller that displays the list of downloaded files.
 */
@interface TDLDownloadTableViewController : UITableViewController <UIActionSheetDelegate> {
 @private
  NSArray *_downloads;
}

/**
 * Refreshes the download list from disk.
 */
- (void)refreshDownloads;

@end
