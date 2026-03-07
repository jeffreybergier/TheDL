#import "XPCURLRequest.h"

#if THEDL_CURL_ENABLED
#include <curl/curl.h>

/**
 * Callback for libcurl to write received data into an NSMutableData object.
 */
static size_t WriteCallback(void *contents, size_t size, size_t nmemb, void *userp) {
  size_t realsize = size * nmemb;
  NSMutableData *data = (NSMutableData *)userp;
  [data appendBytes:contents length:realsize];
  return realsize;
}

/**
 * Callback for libcurl to handle response headers.
 */
static size_t HeaderCallback(void *contents, size_t size, size_t nmemb, void *userp) {
  size_t realsize = size * nmemb;
  NSMutableDictionary *headers = (NSMutableDictionary *)userp;
  
  NSString *headerLine = [[[NSString alloc] initWithBytes:contents
                                                   length:realsize
                                                 encoding:NSUTF8StringEncoding] autorelease];
  
  NSRange separatorRange = [headerLine rangeOfString:@":"];
  if (separatorRange.location != NSNotFound) {
    NSString *key = [[headerLine substringToIndex:separatorRange.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *value = [[headerLine substringFromIndex:separatorRange.location + 1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [headers setObject:value forKey:key];
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
  CURL *curl = curl_easy_init();
  if (!curl) {
    if (outError) {
      *outError = [NSError errorWithDomain:@"XPCURLRequestErrorDomain"
                                      code:-1
                                  userInfo:nil];
    }
    return nil;
  }

  NSMutableData *responseData = [[NSMutableData alloc] init];
  NSMutableDictionary *responseHeadersDict = [[NSMutableDictionary alloc] init];
  struct curl_slist *headerList = NULL;

  // Set URL
  curl_easy_setopt(curl, CURLOPT_URL, [[url absoluteString] UTF8String]);

  // Set HTTP Method
  if ([method isEqualToString:@"POST"]) {
    curl_easy_setopt(curl, CURLOPT_POST, 1L);
  } else if (![method isEqualToString:@"GET"]) {
    curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, [method UTF8String]);
  }

  // Set Request Headers
  if (headers) {
    NSEnumerator *enumerator = [headers keyEnumerator];
    NSString *key;
    while ((key = [enumerator nextObject])) {
      NSString *value = [headers objectForKey:key];
      NSString *headerString = [NSString stringWithFormat:@"%@: %@", key, value];
      headerList = curl_slist_append(headerList, [headerString UTF8String]);
    }
    curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headerList);
  }

  // Set Body
  if (body && [body length] > 0) {
    curl_easy_setopt(curl, CURLOPT_POSTFIELDS, [body bytes]);
    curl_easy_setopt(curl, CURLOPT_POSTFIELDSIZE, (long)[body length]);
  }

  // Set Callbacks
  curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
  curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void *)responseData);
  
  curl_easy_setopt(curl, CURLOPT_HEADERFUNCTION, HeaderCallback);
  curl_easy_setopt(curl, CURLOPT_HEADERDATA, (void *)responseHeadersDict);

  // Set Defaults
  curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L); // Follow redirects
  curl_easy_setopt(curl, CURLOPT_USERAGENT, "TheDL/1.0 (Retro)");
  curl_easy_setopt(curl, CURLOPT_NOSIGNAL, 1L); // Avoid signals in multi-threaded apps
  
  // SSL Defaults
  curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
  curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);

  // Perform Request
  CURLcode res = curl_easy_perform(curl);
  
  NSData *result = nil;
  if (res != CURLE_OK) {
    if (outError) {
      NSString *errorMsg = [NSString stringWithUTF8String:curl_easy_strerror(res)];
      NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorMsg
                                                           forKey:NSLocalizedDescriptionKey];
      *outError = [NSError errorWithDomain:@"XPCURLRequestErrorDomain"
                                      code:res
                                  userInfo:userInfo];
    }
    NSLog(@"[XPCURLRequest] Error: %s", curl_easy_strerror(res));
  } else {
    result = [NSData dataWithData:responseData];
    if (outResponseHeaders) {
      *outResponseHeaders = [NSDictionary dictionaryWithDictionary:responseHeadersDict];
    }
    NSLog(@"[XPCURLRequest] Success: %lu bytes, Content-Type: %@", (unsigned long)[result length], [responseHeadersDict objectForKey:@"Content-Type"]);
  }

  // Cleanup
  if (headerList) {
    curl_slist_free_all(headerList);
  }
  [responseData release];
  [responseHeadersDict release];
  curl_easy_cleanup(curl);

  return result;
}

@end

#endif
