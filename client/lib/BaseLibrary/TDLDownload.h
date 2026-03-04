#import <Foundation/Foundation.h>

/**
 * A data class representing a download item.
 * Compatible with iOS 3.1 and Mac OS X 10.4.
 */
@interface TDLDownload : NSObject {
 @private
  NSString *_displayName;
  NSString *_filePath;
  NSString *_contentType;
  NSString *_requestURL;
  NSString *_responseURL;
  long long _actualSize;
  long long _contentSize;
}

/**
 * Initializes a download object from a PLIST dictionary.
 *
 * @param dict The dictionary containing download properties.
 * @return An initialized TDLDownload instance.
 */
- (id)initWithDictionary:(NSDictionary *)dict;

/**
 * Initializes a download object from a URL pointing to a PLIST on disk.
 *
 * @param url The URL of the PLIST file.
 * @param options Options (not currently used).
 * @param outError Error output.
 * @return An initialized TDLDownload instance.
 */
- (id)initWithURL:(NSURL *)url options:(unsigned int)options error:(NSError **)outError;

/**
 * Returns a dictionary representation suitable for saving to a PLIST.
 *
 * @return An NSDictionary containing the object's properties.
 */
- (NSDictionary *)dictionaryRepresentation;

/** Returns the display name. */
- (NSString *)displayName;
- (void)setDisplayName:(NSString *)name;

/** Returns the local file path. */
- (NSString *)filePath;
- (void)setFilePath:(NSString *)path;

/** Returns the content type (MIME). */
- (NSString *)contentType;
- (void)setContentType:(NSString *)type;

/** Returns the original request URL string. */
- (NSString *)requestURL;
- (void)setRequestURL:(NSString *)url;

/** Returns the final response URL string. */
- (NSString *)responseURL;
- (void)setResponseURL:(NSString *)url;

/** Returns the actual size downloaded so far. */
- (long long)actualSize;
- (void)setActualSize:(long long)size;

/** Returns the expected total content size. */
- (long long)contentSize;
- (void)setContentSize:(long long)size;

@end
