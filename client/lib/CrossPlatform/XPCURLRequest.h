#import <Foundation/Foundation.h>


#if THEDL_CURL_ENABLED

@class XPCURLRequest;

/**
 * Delegate protocol for XPCURLRequest to handle streaming data and lifecycle events.
 */
@protocol XPCURLRequestDelegate <NSObject>
@optional
- (void)xpcRequest:(XPCURLRequest *)request didReceiveResponse:(NSDictionary *)responseHeaders;
- (void)xpcRequest:(XPCURLRequest *)request didReceiveData:(NSData *)data;
- (void)xpcRequest:(XPCURLRequest *)request didFailWithError:(NSError *)error;
- (void)xpcRequestDidFinishLoading:(XPCURLRequest *)request;
@end

/**
 * A lightweight cross-platform wrapper around libcurl.
 * Handles synchronous network requests with legacy compatibility.
 */
@interface XPCURLRequest : NSObject {
 @private
  NSURL *_url;
  NSString *_method;
  NSDictionary *_headers;
  NSData *_body;
  id<XPCURLRequestDelegate> _delegate;
}

/**
 * Initializes a new request.
 */
- (id)initWithURL:(NSURL *)url
           method:(NSString *)method
          headers:(NSDictionary *)headers
             body:(NSData *)body;

/** The delegate to receive updates. */
- (void)setDelegate:(id<XPCURLRequestDelegate>)delegate;
- (id<XPCURLRequestDelegate>)delegate;

/**
 * Starts the request synchronously. 
 * This should usually be called from a background thread.
 */
- (void)start;

/**
 * Performs a synchronous network request using libcurl (Legacy convenience method).
 *
 * @param url The URL to request.
 * @param method The HTTP method (e.g., "GET", "POST").
 * @param headers A dictionary of HTTP headers.
 * @param body The request body data, or nil.
 * @param outResponseHeaders Pointer to an NSDictionary pointer to be set with response headers.
 * @param outError Pointer to an NSError object to be set if an error occurs.
 * @return The response data, or nil if an error occurred.
 */
+ (NSData *)performRequestWithURL:(NSURL *)url
                           method:(NSString *)method
                          headers:(NSDictionary *)headers
                             body:(NSData *)body
                  responseHeaders:(NSDictionary **)outResponseHeaders
                            error:(NSError **)outError;

/**
 * Performs a synchronous download to a file using libcurl.
 *
 * @param url The URL to download.
 * @param method The HTTP method (e.g., "GET", "POST").
 * @param headers A dictionary of HTTP headers.
 * @param body The request body data, or nil.
 * @param fileURL The local file URL to save the data to.
 * @param outResponseHeaders Pointer to an NSDictionary pointer for headers.
 * @param outError Pointer to an NSError object.
 * @return YES if successful, NO otherwise.
 */
+ (BOOL)downloadURL:(NSURL *)url
             method:(NSString *)method
            headers:(NSDictionary *)headers
               body:(NSData *)body
          toFileURL:(NSURL *)fileURL
    responseHeaders:(NSDictionary **)outResponseHeaders
              error:(NSError **)outError;

@end

#endif
