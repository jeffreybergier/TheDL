#import <UIKit/UIKit.h>

/**
 * The primary application delegate for TheDL on iOS.
 */
@interface GTMiOSAppDelegate : NSObject <UIApplicationDelegate> {
 @private
  UIWindow *_window;
  UIViewController *_viewController;
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
