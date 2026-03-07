#import <Foundation/Foundation.h>

/**
 * A lightweight cross-platform wrapper around libcurl.
 * Handles synchronous network requests with legacy compatibility.
 */
@interface XPCURLRequest : NSObject

/**
 * Performs a synchronous network request using libcurl.
 *
 * @param url The URL to request.
 * @param method The HTTP method (e.g., "GET", "POST").
 * @param headers A dictionary of HTTP headers.
 * @param body The request body data, or nil.
 * @param outError Pointer to an NSError object to be set if an error occurs.
 * @return The response data, or nil if an error occurred.
 */
+ (NSData *)performRequestWithURL:(NSURL *)url
                           method:(NSString *)method
                          headers:(NSDictionary *)headers
                             body:(NSData *)body
                            error:(NSError **)outError;

@end
