#import <UIKit/UIKit.h>

@class TDLServiceManager;

/**
 * A grouped table view controller for initiating downloads.
 * Layout:
 * - Section 0: URL input (UITextView) and Start Download button
 * - Section 1: Service selection list
 */
@interface TDLServiceListViewController : UITableViewController <UITextViewDelegate> {
 @private
  UITextView *_urlTextView;
  NSInteger _selectedServiceIndex;
  NSArray *_sampleKeys;
  TDLServiceManager *_serviceManager;
}

/**
 * Initializes the controller with a service manager.
 */
- (id)initWithServiceManager:(TDLServiceManager *)serviceManager;

/**
 * Dismisses the modal view controller.
 */
- (void)dismiss;

/**
 * Initiates the download using the current URL and selected service.
 */
- (void)startDownload;

@end
