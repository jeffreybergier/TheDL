#import <UIKit/UIKit.h>

/**
 * The primary application delegate for TheDL on iOS.
 */
@interface GTMiOSAppDelegate : NSObject <UIApplicationDelegate> {
 @private
  UIWindow *_window;
}

/** The main application window. */
@property(nonatomic, retain) UIWindow *window;

@end
