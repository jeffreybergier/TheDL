#import <UIKit/UIKit.h>

@class TDLDownload;

/**
 * A view controller that displays all metadata for a TDLDownload object.
 */
@interface TDLDownloadInfoViewController : UITableViewController {
 @private
  TDLDownload *_metadata;
  NSURL *_fileURL;
  NSArray *_keys;
  NSDictionary *_data;
}

/**
 * Initializes the info view with metadata and the associated file URL.
 */
- (id)initWithMetadata:(TDLDownload *)metadata fileURL:(NSURL *)url;

@end
