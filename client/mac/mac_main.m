#import <Cocoa/Cocoa.h>
#import "GTMAppDelegate.h"

/**
 * The main entry point for TheDL macOS application.
 */
int main(int argc, const char *argv[]) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  NSLog(@"[main] Initializing NSApplication...");
  
  NSApplication *app = [NSApplication sharedApplication];
  GTMAppDelegate *delegate = [[GTMAppDelegate alloc] init];
  [app setDelegate:delegate];
  
  [app run];
  
  [delegate release];
  [pool drain];
  return 0;
}
