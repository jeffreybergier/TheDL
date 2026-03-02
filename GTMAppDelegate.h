#import <Cocoa/Cocoa.h>

/**
 * The primary application delegate for TheDL on macOS.
 */
@interface GTMAppDelegate : NSObject <NSApplicationDelegate> {
 @private
  NSWindow *_window;
}

/** The main application window. */
@property(nonatomic, retain) NSWindow *window;

@end
