#import <Foundation/Foundation.h>
#import "TDLService.h"
#import "XPCURLRequest.h"

@class TDLDownloadList;

#if THEDL_CURL_ENABLED

/**
 * A service that uses XPCURLRequest (libcurl) to fetch data.
 */
@interface TDLCURLRequestService : NSObject <TDLService, XPCURLRequestDelegate> {
 @private
  NSMutableDictionary *_activeTasks; // XPCURLRequest -> TDLDownloadTask
  NSMutableArray *_taskList;         // Ordered list for UI
  TDLDownloadList *_downloadList;
}

/**
 * Initializes the service.
 */
- (id)initWithDownloadList:(TDLDownloadList *)downloadList;

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
