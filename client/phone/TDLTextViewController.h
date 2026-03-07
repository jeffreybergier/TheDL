#import <UIKit/UIKit.h>

/**
 * A simple view controller to display plain text content from a download.
 */
@interface TDLTextViewController : UIViewController {
 @private
  NSURL *_downloadURL;
  UITextView *_textView;
}

/**
 * Initializes with a download URL.
 */
- (id)initWithDownloadURL:(NSURL *)url;

@end
