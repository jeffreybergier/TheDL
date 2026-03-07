#import <UIKit/UIKit.h>

/**
 * A view controller that displays an image download in a scrollable, zoomable view.
 * Supports pinch-to-zoom and double-tap-to-zoom.
 */
@interface TDLImageViewController : UIViewController <UIScrollViewDelegate> {
 @private
  NSURL *_downloadURL;
  UIScrollView *_scrollView;
  UIImageView *_imageView;
}

/**
 * Initializes the controller with a specific download URL.
 *
 * @param url The URL of the image file to display.
 * @return An initialized instance.
 */
- (id)initWithDownloadURL:(NSURL *)url;

@end
