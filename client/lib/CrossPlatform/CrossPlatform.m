#import "CrossPlatform.h"

NSString *XPGetPlatformName() {
#if TARGET_OS_IPHONE
  return @"iOS";
#else
  return @"macOS";
#endif
}
