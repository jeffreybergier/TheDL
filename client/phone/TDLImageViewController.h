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

/**
 * Dismisses the modal view controller.
 */
- (void)dismiss;

/**
 * Handles a double-tap gesture to toggle zoom.
 */
- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture;

/**
 * Helper to calculate the zoom rectangle for a given scale and center point.
 */
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;

@end
