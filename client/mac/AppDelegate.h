#import <Cocoa/Cocoa.h>
#import "CrossPlatform.h"

/**
 * The primary application delegate for TheDL on macOS.
 */
@interface AppDelegate : NSObject <XPApplicationDelegate> {
 @private
  NSWindow *_window;
}

/** Returns the main application window. */
- (NSWindow *)window;

/**
 * Sets the main application window.
 *
 * @param window The window to set.
 */
- (void)setWindow:(NSWindow *)window;

@end
