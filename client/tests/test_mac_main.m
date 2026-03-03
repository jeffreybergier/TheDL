#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
#import "TDLObjectTests.m"

/**
 * A simple main entry point to run XCTest cases from the command line.
 */
int main(int argc, const char *argv[]) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  XCTestSuite *suite = [XCTestSuite testSuiteForTestCaseClass:[TDLObjectTests class]];
  XCTestRun *run = [suite run];
  
  printf("Tests completed: %lu, failures: %lu\n", 
        (unsigned long)[run testCaseCount], 
        (unsigned long)[run totalFailureCount]);
        
  int exitCode = ([run totalFailureCount] > 0) ? 1 : 0;
  [pool drain];
  return exitCode;
}
