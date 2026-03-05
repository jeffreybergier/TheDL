#import "XPObject.h"

@implementation XPObject

- (NSString *)platformName {
  // TODO: replace with cross-platform platform detection logic.
  return @"Unknown Platform";
}

- (void)dealloc {
  [super dealloc];
}

@end
