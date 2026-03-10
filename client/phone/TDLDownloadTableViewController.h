#import <UIKit/UIKit.h>

@class TDLDownload;

@class TDLDownloadList;
@class TDLServiceManager;

/**
 * A table view controller for displaying the list of downloads on iOS.
 */
@interface TDLDownloadTableViewController : UITableViewController <UIActionSheetDelegate> {
 @private
  NSArray *_downloads;
  TDLDownload *_selectedDownload;
  TDLDownloadList *_downloadList;
}

/**
 * Initializes the controller with a download list.
 */
- (id)initWithDownloadList:(TDLDownloadList *)downloadList;

/**
 * Adds a new download by presenting the service list.
 */
- (void)addDownload;

/**
 * Refreshes the download list from disk.
 */
- (void)refreshDownloads;

/**
 * Opens the download at the given file URL using an appropriate viewer.
 *
 * @param fileURL The local URL of the downloaded file.
 */
- (void)openDownloadWithURL:(NSURL *)fileURL;

@end
