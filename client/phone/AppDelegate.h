#import <UIKit/UIKit.h>

/**
 * The primary application delegate for TheDL on iOS.
 */
@interface AppDelegate : NSObject <UIApplicationDelegate> {
 @private
  UIWindow *_window;
  UITabBarController *_tabBarController;
}

/** Returns the main application window. */
- (UIWindow *)window;

/**
 * Sets the main application window.
 *
 * @param window The window to set.
 */
- (void)setWindow:(UIWindow *)window;

/** Returns the main tab bar controller. */
- (UITabBarController *)tabBarController;

/**
 * Sets the main tab bar controller.
 *
 * @param controller The tab bar controller to set.
 */
- (void)setTabBarController:(UITabBarController *)controller;

@end
