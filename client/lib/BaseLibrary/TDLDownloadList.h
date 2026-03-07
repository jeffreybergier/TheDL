#import <Foundation/Foundation.h>

@class TDLDownload;

/**
 * A central manager for all downloads (in-progress and completed).
 * Metadata is stored in the file's resource fork.
 */
@interface TDLDownloadList : NSObject

/** Returns the shared singleton instance. */
+ (TDLDownloadList *)sharedList;

/**
 * Returns the path to the directory where downloads are stored.
 */
+ (NSString *)downloadsDirectory;
- (NSString *)downloadsDirectory;

/**
 * Returns all download file URLs in the downloads directory sorted by modification date.
 *
 * @return An NSArray of NSURL objects.
 */
- (NSArray *)allDownloads;

/**
 * Loads and returns a TDLDownload metadata object from a file's resource fork.
 *
 * @param url The URL to the data file.
 * @return A TDLDownload object, or nil if no metadata exists.
 */
- (TDLDownload *)getTDLDownloadForURL:(NSURL *)url;

/**
 * Persists a download object's metadata to a file's resource fork.
 * 
 * @param download The metadata to save.
 * @param url The URL of the file to attach metadata to.
 */
- (void)saveDownload:(TDLDownload *)download forURL:(NSURL *)url;

/**
 * Deletes a file and its integrated metadata from disk.
 */
- (void)deleteFileAtURL:(NSURL *)url;

@end
