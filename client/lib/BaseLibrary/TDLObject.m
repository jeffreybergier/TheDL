#import "TDLObject.h"

@implementation TDLObject

- (int)tag {
  return _tag;
}

- (void)setTag:(int)tag {
  _tag = tag;
}

- (NSString *)platformInfo {
  XPObject *xp = [[XPObject alloc] init];
  NSString *platform = [xp platformName];
  NSString *info = [NSString stringWithFormat:@"TDL Object on %@", platform];
  [xp release];
  return info;
}

@end
