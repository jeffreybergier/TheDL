#import <UIKit/UIKit.h>

@class TDLCURLRequestService;

/**
 * A grouped table view controller for interacting with the CURLRequest service.
 */
@interface TDLCURLRequestServiceTableViewController : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate> {
 @private
  TDLCURLRequestService *_service;
  UITextField *_urlField;
}

/**
 * Initializes the controller with a specific service.
 *
 * @param service The CURLRequest service instance.
 * @return An initialized instance.
 */
- (id)initWithService:(TDLCURLRequestService *)service;

@end
