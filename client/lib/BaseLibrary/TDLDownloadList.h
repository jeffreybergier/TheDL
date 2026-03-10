#import <Foundation/Foundation.h>

@class TDLDownload;

/** Notification posted when a download is updated. UserInfo contains the NSURL. */
extern NSString *const TDLDownloadListUpdatedNotification;

/**
 * A central manager for all downloads (in-progress and completed).
 * Metadata is stored in the file's resource fork.
 */
@interface TDLDownloadList : NSObject {
 @private
  NSURL *_downloadsDirectoryURL;
}

/**
 * Initializes a new download list manager.
 *
 * @param url The local directory URL where downloads are stored.
 */
- (id)initWithDownloadsDirectoryURL:(NSURL *)url;

/**
 * Returns the URL to the directory where downloads are stored.
 */
- (NSURL *)downloadsDirectoryURL;

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
