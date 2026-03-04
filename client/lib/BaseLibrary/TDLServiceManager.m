#import "TDLServiceManager.h"
#import "TDLURLConnectionService.h"

@implementation TDLServiceManager

+ (TDLServiceManager *)sharedManager {
  static TDLServiceManager *sharedInstance = nil;
  if (!sharedInstance) {
    sharedInstance = [[TDLServiceManager alloc] init];
  }
  return sharedInstance;
}

- (id)init {
  self = [super init];
  if (self) {
    _services = [[NSArray alloc] initWithObjects:
                 [TDLURLConnectionService sharedService], nil];
  }
  return self;
}

- (void)dealloc {
  [_services release];
  [super dealloc];
}

- (NSArray *)availableServices {
  return _services;
}

@end
