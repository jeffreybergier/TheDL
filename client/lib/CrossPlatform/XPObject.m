#import "XPObject.h"
#import "CrossPlatform.h"

@implementation XPObject

- (NSString *)platformName {
  return XPGetPlatformName();
}

- (void)dealloc {
  [super dealloc];
}

@end
