#import <Foundation/Foundation.h>

typedef enum {
  TDLDownloadStatePending,
  TDLDownloadStateDownloading,
  TDLDownloadStateFinished,
  TDLDownloadStateFailed
} TDLDownloadState;

/**
 * A metadata class representing a download's extra information.
 * This is stored in the file's resource fork as a PLIST.
 */
@interface TDLDownload : NSObject {
 @private
  NSString *_contentType;
  NSString *_requestURL;
  NSString *_responseURL;
  NSString *_serviceIdentifier;
  TDLDownloadState _state;
  long long _contentSize;
  NSString *_errorMessage;
}

- (id)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

/** Returns the MIME content type. */
- (NSString *)contentType;
- (void)setContentType:(NSString *)type;

/** Returns the initial request URL. */
- (NSString *)requestURL;
- (void)setRequestURL:(NSString *)url;

/** Returns the final response URL (after redirects). */
- (NSString *)responseURL;
- (void)setResponseURL:(NSString *)url;

/** Returns the ID of the service that handled this download. */
- (NSString *)serviceIdentifier;
- (void)setServiceIdentifier:(NSString *)ident;

/** Returns the current state of the download. */
- (TDLDownloadState)state;
- (void)setState:(TDLDownloadState)state;

/** Returns the expected total content size from headers. */
- (long long)contentSize;
- (void)setContentSize:(long long)size;

/** Returns the error message if state is Failed. */
- (NSString *)errorMessage;
- (void)setErrorMessage:(NSString *)msg;

@end
