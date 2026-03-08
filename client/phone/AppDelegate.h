#import <UIKit/UIKit.h>

/**
 * The primary application delegate for TheDL on iOS.
 */
@interface AppDelegate : NSObject <UIApplicationDelegate> {
 @private
  UIWindow *_window;
  UINavigationController *_navigationController;
}

/** Returns the main application window. */
- (UIWindow *)window;

/**
 * Sets the main application window.
 *
 * @param window The window to set.
 */
- (void)setWindow:(UIWindow *)window;

/** Returns the main navigation controller. */
- (UINavigationController *)navigationController;

/**
 * Sets the main navigation controller.
 *
 * @param controller The navigation controller to set.
 */
- (void)setNavigationController:(UINavigationController *)controller;

@end
