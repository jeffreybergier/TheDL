#import "XPObject.h"
#include <TargetConditionals.h>

@implementation XPObject

- (NSString *)platformName {
#if TARGET_OS_IPHONE
  return @"iOS";
#elif TARGET_OS_MAC
  return @"macOS";
#else
  return @"Unknown Platform";
#endif
}

@end
