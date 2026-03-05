#import <Foundation/Foundation.h>

@class TDLDownload;

/**
 * A central manager for all downloads (in-progress and completed).
 */
@interface TDLDownloadList : NSObject {
 @private
  NSMutableDictionary *_downloadCache; // udid -> TDLDownload
}

/** Returns the shared singleton instance. */
+ (TDLDownloadList *)sharedList;

/**
 * Returns all downloads managed by the list.
 *
 * @return An NSArray of TDLDownload objects.
 */
- (NSArray *)allDownloads;

/**
 * Returns a download by its UDID.
 */
- (TDLDownload *)downloadWithUdid:(NSString *)udid;

/**
 * Creates and registers a new download object.
 */
- (TDLDownload *)createDownload;

/**
 * Persists a download object's metadata to disk.
 */
- (void)saveDownload:(TDLDownload *)download;

/**
 * Debug helper to create fake download PLISTs.
 */
+ (void)__DEBUG_createFakeData;

@end
