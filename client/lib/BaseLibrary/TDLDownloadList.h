#import <Foundation/Foundation.h>

@class TDLDownload;

/**
 * A central manager for all downloads (in-progress and completed).
 */
@interface TDLDownloadList : NSObject {
 @private
  NSMutableDictionary *_downloadCache; // udid -> TDLDownload (optional cache)
}

/** Returns the shared singleton instance. */
+ (TDLDownloadList *)sharedList;

/**
 * Returns the path to the directory where downloads are stored.
 */
+ (NSString *)downloadsDirectory;
- (NSString *)downloadsDirectory;

/**
 * Returns all download metadata URLs (.plist files) sorted by modification date.
 *
 * @return An NSArray of NSURL objects.
 */
- (NSArray *)allDownloads;

/**
 * Loads and returns a TDLDownload object from a metadata URL.
 *
 * @param url The URL to the .plist file.
 * @return A TDLDownload object, or nil if loading fails.
 */
- (TDLDownload *)getTDLDownloadForURL:(NSURL *)url;

/**
 * Loads and returns the raw data associated with a metadata URL.
 *
 * @param url The URL to the .plist file.
 * @return The NSData of the downloaded file, or nil if not found.
 */
- (NSData *)getDataForURL:(NSURL *)url;

/**
 * Creates and registers a new download object.
 */
- (TDLDownload *)createDownload;

/**
 * Persists a download object's metadata to disk.
 */
- (void)saveDownload:(TDLDownload *)download;

/**
 * Deletes a download object and its files from disk.
 */
- (void)deleteDownload:(TDLDownload *)download;

@end
