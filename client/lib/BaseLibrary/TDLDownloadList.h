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
 * Returns the path to the directory where downloads are stored.
 */
- (NSString *)downloadsDirectory;

/**
 * Loads downloads from disk into the cache.
 */
- (void)loadDownloadsFromDisk;

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

@end
