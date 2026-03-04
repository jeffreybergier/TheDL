#import <UIKit/UIKit.h>

/**
 * A table view controller for displaying the list of downloads on iOS.
 */
@interface DownloadsTableViewController : UITableViewController {
 @private
  NSArray *_downloads;
}

/**
 * Refreshes the list of downloads from the Documents directory.
 */
- (void)refreshDownloads;

@end
