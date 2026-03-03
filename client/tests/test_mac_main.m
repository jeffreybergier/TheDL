#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
#import "TDLObjectTests.m"
#import "TDLDownloadTests.m"

/**
 * A simple main entry point to run XCTest cases from the command line.
 */
int main(int argc, const char *argv[]) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  XCTestSuite *suite = [XCTestSuite defaultTestSuite];
  XCTestRun *run = [suite run];
  
  printf("Mac Tests completed: %lu, failures: %lu\n", 
        (unsigned long)[run testCaseCount], 
        (unsigned long)[run totalFailureCount]);
        
  int exitCode = ([run totalFailureCount] > 0) ? 1 : 0;
  [pool drain];
  return exitCode;
}
