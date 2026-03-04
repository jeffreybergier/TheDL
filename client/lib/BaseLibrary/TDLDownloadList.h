#import <Foundation/Foundation.h>

/**
 * A utility class for managing the list of downloads.
 */
@interface TDLDownloadList : NSObject

/**
 * Loads and returns all TDLDownload objects found in the Documents directory.
 *
 * @return An NSArray of TDLDownload objects.
 */
+ (NSArray *)allDownloads;

/**
 * Debug helper to create fake download PLISTs in the Documents directory.
 */
+ (void)__DEBUG_createFakeData;

@end
