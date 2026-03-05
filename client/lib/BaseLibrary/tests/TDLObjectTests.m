#import "TDLObjectTests.h"
#import "TDLObject.h"

@implementation TDLObjectTests

- (void)testTagAssignment {
  TDLObject *object = [[TDLObject alloc] init];
  [object setTag:42];
  XCTAssertEqual([object tag], 42, @"Tag should be correctly assigned and retrieved.");
  [object release];
}

- (void)testPlatformInfo {
  TDLObject *object = [[TDLObject alloc] init];
  NSString *info = [object platformInfo];
  XCTAssertNotNil(info, @"Platform info should not be nil.");
  XCTAssertTrue([info length] > 0, @"Platform info should have content.");
  [object release];
}

@end
