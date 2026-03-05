#import "XPObjectTests.h"
#import "XPObject.h"

@implementation XPObjectTests

- (void)testPlatformName {
  XPObject *object = [[XPObject alloc] init];
  NSString *name = [object platformName];
  XCTAssertNotNil(name, @"Platform name should not be nil.");
  XCTAssertTrue([name length] > 0, @"Platform name should have content.");
  [object release];
}

@end
