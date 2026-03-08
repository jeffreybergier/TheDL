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

/**
 * Private methods for TDLURLConnectionService.
 */
@interface TDLURLConnectionService (Private)

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end
