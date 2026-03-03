#import <Foundation/Foundation.h>

#if !TARGET_OS_IPHONE
#import <AppKit/AppKit.h>
#endif

/**
 * A file wrapper subclass for storing download payloads and metadata.
 */
@interface TDLDownload : NSFileWrapper {
 @private
  NSString *_filename;
  NSString *_contentType;
}

/**
 * Initializes a new download wrapper with data and metadata.
 *
 * @param data The blob of data to store.
 * @param filename The original filename of the download.
 * @param contentType The MIME content-type of the download.
 * @return An initialized TDLDownload instance.
 */
- (id)initWithData:(NSData *)data 
          filename:(NSString *)filename 
       contentType:(NSString *)contentType;

/** Returns the stored filename. */
- (NSString *)filename;

/** Returns the stored content-type. */
- (NSString *)contentType;

/** Returns the stored data blob. */
- (NSData *)regularFileContents;

@end
