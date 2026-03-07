#import <UIKit/UIKit.h>

@class TDLDownload;

/**
 * A view controller that displays all metadata for a TDLDownload object.
 */
@interface TDLDownloadInfoViewController : UITableViewController {
 @private
  TDLDownload *_download;
  NSArray *_keys;
  NSDictionary *_data;
}

/**
 * Initializes the info view with a download object.
 */
- (id)initWithDownload:(TDLDownload *)download;

@end
