#import <UIKit/UIKit.h>

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
}

@end
