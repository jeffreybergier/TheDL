#import "GTMAppDelegate.h"

@implementation GTMAppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  NSLog(@"[GTMAppDelegate applicationDidFinishLaunching:] Started TheDL on macOS.");

  NSRect frame = NSMakeRect(0, 0, 480, 320);
  NSUInteger styleMask = NSTitledWindowMask | NSClosableWindowMask |
                         NSMiniaturizableWindowMask | NSResizableWindowMask;

  _window = [[NSWindow alloc] initWithContentRect:frame
                                       styleMask:styleMask
                                         backing:NSBackingStoreBuffered
                                           defer:NO];
  [_window setTitle:@"TheDL"];
  [_window center];
  [_window makeKeyAndOrderFront:nil];
}

- (void)dealloc {
  [_window release];
  [super dealloc];
}

@end
