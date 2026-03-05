#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "TDLObjectTests.h"
#import "TDLDownloadTests.h"
#import "TDLURLConnectionServiceTests.h"

/**
 * A simple main entry point to run XCTest cases from the command line on iOS Simulator.
 */
int main(int argc, char *argv[]) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  // We don't need a full UIApplication for these logic tests, 
  // but XCTest expects a runtime environment.
  XCTestSuite *suite = [XCTestSuite defaultTestSuite];
  XCTestRun *run = [suite run];
  
  printf("iOS Simulator Tests completed: %lu, failures: %lu\n", 
        (unsigned long)[run testCaseCount], 
        (unsigned long)[run totalFailureCount]);
        
  int exitCode = ([run totalFailureCount] > 0) ? 1 : 0;
  [pool drain];
  return exitCode;
}
