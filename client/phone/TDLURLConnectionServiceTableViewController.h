#import <UIKit/UIKit.h>

@class TDLURLConnectionService;

/**
 * A grouped table view controller for interacting with the NSURLConnection service.
 */
@interface TDLURLConnectionServiceTableViewController : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate> {
 @private
  TDLURLConnectionService *_service;
  UITextField *_urlField;
  NSTimer *_refreshTimer;
}

/**
 * Initializes the controller with a specific service.
 *
 * @param service The NSURLConnection service instance.
 * @return An initialized instance.
 */
- (id)initWithService:(TDLURLConnectionService *)service;

@end
