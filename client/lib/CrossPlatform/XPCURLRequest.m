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

@implementation XPCURLRequest

+ (NSData *)performRequestWithURL:(NSURL *)url
                           method:(NSString *)method
                          headers:(NSDictionary *)headers
                             body:(NSData *)body
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
  struct curl_slist *headerList = NULL;

  // Set URL
  curl_easy_setopt(curl, CURLOPT_URL, [[url absoluteString] UTF8String]);

  // Set HTTP Method
  curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, [method UTF8String]);

  // Set Headers
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

  // Set Defaults
  curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L); // Follow redirects
  curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
  curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void *)responseData);
  curl_easy_setopt(curl, CURLOPT_USERAGENT, "TheDL/1.0 (Retro)");
  
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
  } else {
    result = [NSData dataWithData:responseData];
  }

  // Cleanup
  if (headerList) {
    curl_slist_free_all(headerList);
  }
  [responseData release];
  curl_easy_cleanup(curl);

  return result;
}

@end

#endif