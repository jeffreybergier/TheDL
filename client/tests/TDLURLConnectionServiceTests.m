#import "TDLURLConnectionServiceTests.h"
#import "TDLURLConnectionService.h"

@implementation TDLURLConnectionServiceTests

- (void)testSingleton {
  TDLURLConnectionService *s1 = [TDLURLConnectionService sharedService];
  TDLURLConnectionService *s2 = [TDLURLConnectionService sharedService];
  XCTAssertEqualObjects(s1, s2, @"Service should be a singleton.");
}

- (void)testName {
  TDLURLConnectionService *service = [TDLURLConnectionService sharedService];
  XCTAssertEqualObjects([service serviceName], @"NSURLConnection", @"Service name should match.");
}

@end
