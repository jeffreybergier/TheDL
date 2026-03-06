#import "XPObject.h"
#import "CrossPlatform.h"

@implementation XPObject

- (NSString *)platformName {
#if TARGET_OS_IPHONE
  return @"iOS";
#else
  return @"macOS";
#endif
}

- (void)dealloc {
  [super dealloc];
}

@end
