#import <UIKit/UIKit.h>

@class TDLDownload;
@class MPMoviePlayerController;

/**
 * A table view controller for displaying the list of downloads on iOS.
 */
@interface TDLDownloadTableViewController : UITableViewController <UIActionSheetDelegate> {
 @private
  NSArray *_downloads;
  TDLDownload *_selectedDownload;
  MPMoviePlayerController *_moviePlayer;
}


/**
 * Refreshes the download list from disk.
 */
- (void)refreshDownloads;

@end
