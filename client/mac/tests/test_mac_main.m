#import <XCTest/XCTest.h>

/**
 * Main entry point for macOS Application unit tests.
 * Library tests are handled by their respective modules.
 */
int main(int argc, char *argv[]) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  NSLog(@"Running macOS Application Unit Tests...");
  
  // This runner can be used for app-level UI or integration tests later.
  // For now, it just initializes the XCTest environment.
  
  [pool drain];
  return 0;
}
