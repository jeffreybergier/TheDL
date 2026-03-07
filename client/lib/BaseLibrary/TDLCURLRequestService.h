#import "TDLService.h"

/**
 * A service that uses XPCURLRequest (libcurl) to fetch data.
 */
@interface TDLCURLRequestService : TDLService {
 @private
  NSMutableArray *_taskList; // Ordered list for UI
}

/** Returns the shared instance of the service. */
+ (TDLCURLRequestService *)sharedService;

@end
