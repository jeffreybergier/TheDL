#import "TDLService.h"

/**
 * A service that uses NSURLConnection to fetch data.
 */
@interface TDLURLConnectionService : TDLService {
 @private
  NSMutableDictionary *_activeTasks; // NSURLConnection -> TDLDownloadTask
  NSMutableArray *_taskList;         // Ordered list for UI
}

/** Returns the shared instance of the service. */
+ (TDLURLConnectionService *)sharedService;

@end
