#import <Foundation/Foundation.h>

typedef enum {
  TDLDownloadStatePending,
  TDLDownloadStateDownloading,
  TDLDownloadStateFinished,
  TDLDownloadStateFailed
} TDLDownloadState;

/**
 * A data class representing a download item.
 * Compatible with iOS 3.1 and Mac OS X 10.4.
 */
@interface TDLDownload : NSObject {
 @private
  NSString *_udid;
  NSString *_displayName;
  NSString *_filePath;
  NSString *_contentType;
  NSString *_requestURL;
  NSString *_responseURL;
  NSString *_serviceIdentifier;
  TDLDownloadState _state;
  long long _actualSize;
  long long _contentSize;
  NSString *_errorMessage;
}

/**
 * Initializes a download object from a PLIST dictionary.
 *
 * @param dict The dictionary containing download properties.
 * @return An initialized TDLDownload instance.
 */
- (id)initWithDictionary:(NSDictionary *)dict;

/**
 * Returns a dictionary representation suitable for saving to a PLIST.
 *
 * @return An NSDictionary containing the object's properties.
 */
- (NSDictionary *)dictionaryRepresentation;

/** Returns the unique identifier for this download. */
- (NSString *)udid;
- (void)setUdid:(NSString *)udid;

/** Returns the display name. */
- (NSString *)displayName;
- (void)setDisplayName:(NSString *)name;

/** Returns the local file path for the data blob. */
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

/** Returns the identifier of the service handling this download. */
- (NSString *)serviceIdentifier;
- (void)setServiceIdentifier:(NSString *)ident;

/** Returns the current state of the download. */
- (TDLDownloadState)state;
- (void)setState:(TDLDownloadState)state;

/** Returns the actual size downloaded so far. */
- (long long)actualSize;
- (void)setActualSize:(long long)size;

/** Returns the expected total content size. */
- (long long)contentSize;
- (void)setContentSize:(long long)size;

/** Returns the error message if state is Failed. */
- (NSString *)errorMessage;
- (void)setErrorMessage:(NSString *)msg;

@end
