#import <UIKit/UIKit.h>

@class TDLDownload;

/**
 * A simple view controller to display plain text content from a download.
 */
@interface TDLTextViewController : UIViewController {
 @private
  TDLDownload *_download;
  UITextView *_textView;
}

/**
 * Initializes with a download object.
 */
- (id)initWithDownload:(TDLDownload *)download;

@end
