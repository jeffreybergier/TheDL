#import "XPCURLRequest.h"

#if THEDL_CURL_ENABLED
#include <curl/curl.h>

/**
 * Internal delegate class for static convenience methods.
 */
@interface XPCStaticRequestDelegate : NSObject <XPCURLRequestDelegate> {
 @public
  NSMutableData *_responseData;
  NSMutableDictionary *_responseHeaders;
  NSError *_error;
  BOOL _finished;
  NSFileHandle *_fileHandle;
}
@end

@implementation XPCStaticRequestDelegate

- (id)init {
  self = [super init];
  if (self) {
    _responseData = [[NSMutableData alloc] init];
    _responseHeaders = [[NSMutableDictionary alloc] init];
    _finished = NO;
  }
  return self;
}

- (void)dealloc {
  [_responseData release];
  [_responseHeaders release];
  [_error release];
  [_fileHandle release];
  [super dealloc];
}

- (void)xpcRequest:(XPCURLRequest *)request didReceiveResponse:(NSDictionary *)responseHeaders {
  [_responseHeaders addEntriesFromDictionary:responseHeaders];
}

- (void)xpcRequest:(XPCURLRequest *)request didReceiveData:(NSData *)data {
  if (_fileHandle) {
    [_fileHandle writeData:data];
  } else {
    [_responseData appendData:data];
  }
}

- (void)xpcRequest:(XPCURLRequest *)request didFailWithError:(NSError *)error {
  _error = [error retain];
  _finished = YES;
}

- (void)xpcRequestDidFinishLoading:(XPCURLRequest *)request {
  _finished = YES;
}

@end

/**
 * Callback for libcurl to handle response headers and populate a dictionary.
 */
static size_t HeaderCallback(void *contents, size_t size, size_t nmemb, void *userp) {
  size_t realsize = size * nmemb;
  NSMutableDictionary *headers = (NSMutableDictionary *)userp;
  
  NSString *headerLine = [[[NSString alloc] initWithBytes:contents
                                                   length:realsize
                                                 encoding:NSUTF8StringEncoding] autorelease];
  
  // A blank line (just \r\n) indicates the end of headers for this block
  if ([headerLine isEqualToString:@"\r\n"] || [headerLine isEqualToString:@"\n"]) {
    [headers setObject:@"YES" forKey:@"__XPC_HEADERS_COMPLETE__"];
  }

  NSRange separatorRange = [headerLine rangeOfString:@":"];
  if (separatorRange.location != NSNotFound) {
    NSString *key = [[[headerLine substringToIndex:separatorRange.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    NSString *value = [[headerLine substringFromIndex:separatorRange.location + 1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [headers setObject:value forKey:key];
  }
  
  return realsize;
}

/**
 * Callback for libcurl to write received data and pass it to the delegate.
 */
static size_t DelegateWriteCallback(void *contents, size_t size, size_t nmemb, void *userp) {
  size_t realsize = size * nmemb;
  XPCURLRequest *request = (XPCURLRequest *)userp;
  
#ifdef DEBUG
  NSLog(@"[XPCURLRequest] Received chunk: %lu bytes", (unsigned long)realsize);
  // Manual throttle (50ms per chunk) to allow UI testing without being too slow
  usleep(50000);
#endif

  // Check if we need to notify about headers before the first chunk
  NSMutableDictionary *headers = request->_responseHeaders;
  if ([headers objectForKey:@"__XPC_HEADERS_COMPLETE__"]) {
    if ([[request delegate] respondsToSelector:@selector(xpcRequest:didReceiveResponse:)]) {
      [[request delegate] xpcRequest:request didReceiveResponse:headers];
    }
    // Remove the flag so we don't notify again
    [headers removeObjectForKey:@"__XPC_HEADERS_COMPLETE__"];
  }

  if ([[request delegate] respondsToSelector:@selector(xpcRequest:didReceiveData:)]) {
    NSData *data = [[NSData alloc] initWithBytesNoCopy:contents length:realsize freeWhenDone:NO];
    [[request delegate] xpcRequest:request didReceiveData:data];
    [data release];
  }
  
  return realsize;
}

@implementation XPCURLRequest

+ (NSData *)performRequestWithURL:(NSURL *)url
                           method:(NSString *)method
                          headers:(NSDictionary *)headers
                             body:(NSData *)body
                  responseHeaders:(NSDictionary **)outResponseHeaders
                            error:(NSError **)outError {
  XPCURLRequest *request = [[XPCURLRequest alloc] initWithURL:url
                                                       method:method
                                                      headers:headers
                                                         body:body];
  XPCStaticRequestDelegate *delegate = [[XPCStaticRequestDelegate alloc] init];
  [request setDelegate:delegate];
  [request start];
  
  NSData *result = nil;
  if (delegate->_error) {
    if (outError) *outError = delegate->_error;
  } else {
    result = [NSData dataWithData:delegate->_responseData];
    if (outResponseHeaders) {
      *outResponseHeaders = [NSDictionary dictionaryWithDictionary:delegate->_responseHeaders];
    }
  }
  
  [delegate release];
  [request release];
  return result;
}

+ (BOOL)downloadURL:(NSURL *)url
             method:(NSString *)method
            headers:(NSDictionary *)headers
               body:(NSData *)body
          toFileURL:(NSURL *)fileURL
    responseHeaders:(NSDictionary **)outResponseHeaders
              error:(NSError **)outError {
  XPCURLRequest *request = [[XPCURLRequest alloc] initWithURL:url
                                                       method:method
                                                      headers:headers
                                                         body:body];
  XPCStaticRequestDelegate *delegate = [[XPCStaticRequestDelegate alloc] init];
  
  NSError *fileError = nil;
  delegate->_fileHandle = [[NSFileHandle fileHandleForWritingToURL:fileURL error:&fileError] retain];
  if (!delegate->_fileHandle) {
    if (outError) *outError = fileError;
    [delegate release];
    [request release];
    return NO;
  }
  [delegate->_fileHandle truncateFileAtOffset:0];

  [request setDelegate:delegate];
  [request start];
  
  BOOL success = NO;
  if (delegate->_error) {
    if (outError) *outError = delegate->_error;
  } else if (delegate->_finished) {
    success = YES;
    if (outResponseHeaders) {
      *outResponseHeaders = [NSDictionary dictionaryWithDictionary:delegate->_responseHeaders];
    }
  }
  
  [delegate release];
  [request release];
  return success;
}

- (id)initWithURL:(NSURL *)url
           method:(NSString *)method
          headers:(NSDictionary *)headers
             body:(NSData *)body {
  self = [super init];
  if (self) {
    _url = [url retain];
    _method = [method copy];
    _headers = [headers retain];
    _body = [body retain];
    _responseHeaders = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)dealloc {
  [_url release];
  [_method release];
  [_headers release];
  [_body release];
  [_responseHeaders release];
  [super dealloc];
}

- (void)setDelegate:(id<XPCURLRequestDelegate>)delegate {
  _delegate = delegate;
}

- (id<XPCURLRequestDelegate>)delegate {
  return _delegate;
}

- (void)start {
#ifdef DEBUG
  NSLog(@"[XPCURLRequest] DEBUG mode: Throttling enabled (50KB/s)");
#else
  NSLog(@"[XPCURLRequest] RELEASE mode: No throttling");
#endif

  CURL *curl = curl_easy_init();
  if (!curl) {
    if ([_delegate respondsToSelector:@selector(xpcRequest:didFailWithError:)]) {
      NSError *error = [NSError errorWithDomain:@"XPCURLRequestErrorDomain" code:-1 userInfo:nil];
      [_delegate xpcRequest:self didFailWithError:error];
    }
    return;
  }

  struct curl_slist *headerList = NULL;

  curl_easy_setopt(curl, CURLOPT_URL, [[_url absoluteString] UTF8String]);

  if ([_method isEqualToString:@"POST"]) {
    curl_easy_setopt(curl, CURLOPT_POST, 1L);
  } else if (![_method isEqualToString:@"GET"]) {
    curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, [_method UTF8String]);
  }

  if (_headers) {
    NSEnumerator *enumerator = [_headers keyEnumerator];
    NSString *key;
    while ((key = [enumerator nextObject])) {
      NSString *value = [_headers objectForKey:key];
      NSString *headerString = [NSString stringWithFormat:@"%@: %@", key, value];
      headerList = curl_slist_append(headerList, [headerString UTF8String]);
    }
    curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headerList);
  }

  if (_body && [_body length] > 0) {
    curl_easy_setopt(curl, CURLOPT_POSTFIELDS, [_body bytes]);
    curl_easy_setopt(curl, CURLOPT_POSTFIELDSIZE, (long)[_body length]);
  }

  curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, DelegateWriteCallback);
  curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void *)self);
  
  curl_easy_setopt(curl, CURLOPT_HEADERFUNCTION, HeaderCallback);
  curl_easy_setopt(curl, CURLOPT_HEADERDATA, (void *)_responseHeaders);

  curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
  curl_easy_setopt(curl, CURLOPT_USERAGENT, "TheDL/1.0 (Retro)");
  curl_easy_setopt(curl, CURLOPT_NOSIGNAL, 1L);
  curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
  curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);

#ifdef DEBUG
  // Throttle to ~50 KB/s in debug mode to test UI features
  curl_easy_setopt(curl, CURLOPT_MAX_RECV_SPEED_LARGE, (curl_off_t)51200);
#endif

  CURLcode res = curl_easy_perform(curl);
  
  if (res != CURLE_OK) {
    if ([_delegate respondsToSelector:@selector(xpcRequest:didFailWithError:)]) {
      NSString *errorMsg = [NSString stringWithUTF8String:curl_easy_strerror(res)];
      NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorMsg
                                                           forKey:NSLocalizedDescriptionKey];
      NSError *error = [NSError errorWithDomain:@"XPCURLRequestErrorDomain"
                                           code:res
                                       userInfo:userInfo];
      [_delegate xpcRequest:self didFailWithError:error];
    }
  } else {
    // Notify about finish
    if ([_delegate respondsToSelector:@selector(xpcRequestDidFinishLoading:)]) {
      [_delegate xpcRequestDidFinishLoading:self];
    }
  }

  if (headerList) {
    curl_slist_free_all(headerList);
  }
  curl_easy_cleanup(curl);
}

@end

#endif
