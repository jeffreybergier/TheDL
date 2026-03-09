#import "TDLService.h"
#import "XPCURLRequest.h"

#if THEDL_CURL_ENABLED

/**
 * A service that uses XPCURLRequest (libcurl) to fetch data.
 */
@interface TDLCURLRequestService : TDLService <XPCURLRequestDelegate> {
 @private
  NSMutableDictionary *_activeTasks; // XPCURLRequest -> TDLDownloadTask
  NSMutableArray *_taskList;         // Ordered list for UI
}

/** Returns the shared instance of the service. */
+ (TDLCURLRequestService *)sharedService;

@end

/**
 * Private methods for TDLCURLRequestService.
 */
@interface TDLCURLRequestService (Private)

/**
 * Performs the actual CURL fetch on a background thread.
 *
 * @param info A dictionary containing the metadata and file URL.
 */
- (void)performFetchWithInfo:(NSDictionary *)info;

@end

#endif
