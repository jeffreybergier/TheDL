#import "TDLServiceManager.h"
#import "TDLURLConnectionService.h"
#import "TDLCURLRequestService.h"

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
    NSMutableArray *services = [[NSMutableArray alloc] init];
    [services addObject:[TDLURLConnectionService sharedService]];
    
#if THEDL_CURL_ENABLED
    [services addObject:[TDLCURLRequestService sharedService]];
#endif
    
    _services = [services copy];
    [services release];
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
