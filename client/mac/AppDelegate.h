#import <Cocoa/Cocoa.h>

/**
 * The primary application delegate for TheDL on macOS.
 */
#if defined(__MAC_10_6)
@interface AppDelegate : NSObject <NSApplicationDelegate> {
#else
@interface AppDelegate : NSObject {
#endif
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
