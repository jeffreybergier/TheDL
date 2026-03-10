#import <UIKit/UIKit.h>

/**
 * The primary application delegate for TheDL on iOS.
 */
@class TDLDownloadList;
@class TDLServiceManager;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
 @private
  UIWindow *_window;
  UINavigationController *_navigationController;
  TDLDownloadList *_downloadList;
  TDLServiceManager *_serviceManager;
}

/** The central download list manager. */
- (TDLDownloadList *)downloadList;

/** The manager for download services. */
- (TDLServiceManager *)serviceManager;

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
