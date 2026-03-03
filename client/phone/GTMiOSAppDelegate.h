#import <UIKit/UIKit.h>

@class RootViewController;

/**
 * The primary application delegate for TheDL on iOS.
 */
@interface GTMiOSAppDelegate : NSObject <UIApplicationDelegate> {
 @private
  UIWindow *_window;
  UINavigationController *_navigationController;
  RootViewController *_rootViewController;
}

/** Returns the main application window. */
- (UIWindow *)window;

/**
 * Sets the main application window.
 *
 * @param window The window to set.
 */
- (void)setWindow:(UIWindow *)window;

@end
