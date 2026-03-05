#import <UIKit/UIKit.h>

@class TDLDownload;

/**
 * A view controller that displays an image download in a scrollable, zoomable view.
 * Supports pinch-to-zoom and double-tap-to-zoom.
 */
@interface TDLImageViewController : UIViewController <UIScrollViewDelegate> {
 @private
  TDLDownload *_download;
  UIScrollView *_scrollView;
  UIImageView *_imageView;
}

/**
 * Initializes the controller with a specific download.
 *
 * @param download The download containing the image to display.
 * @return An initialized instance.
 */
- (id)initWithDownload:(TDLDownload *)download;

@end
