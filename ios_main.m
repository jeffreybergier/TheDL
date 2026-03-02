#import <UIKit/UIKit.h>
#import "GTMiOSAppDelegate.h"

/**
 * The main entry point for TheDL iOS application.
 */
int main(int argc, char *argv[]) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  NSLog(@"[main] Initializing UIApplication...");
  
  int retVal = UIApplicationMain(argc, argv, nil, @"GTMiOSAppDelegate");
  
  [pool drain];
  return retVal;
}
