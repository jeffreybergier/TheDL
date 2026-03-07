#import "CrossPlatform.h"

#if THEDL_CURL_ENABLED
#import <curl/curl.h>
#import <openssl/opensslv.h>
#import <zlib.h>
#endif

void XPLogLibraryVersions() {
  NSLog(@"--- Library Versions ---");
#if TARGET_OS_IPHONE
  NSLog(@"[OS] iOS %@", [[UIDevice currentDevice] systemVersion]);
#else
  NSLog(@"[OS] macOS %@", [[NSProcessInfo processInfo] operatingSystemVersionString]);
#endif

#if THEDL_CURL_ENABLED
  NSLog(@"[CURL] %s", curl_version());
  NSLog(@"[OpenSSL] %s", OPENSSL_VERSION_TEXT);
  NSLog(@"[zlib] %s", ZLIB_VERSION);
#else
  NSLog(@"[CURL] Not Linked");
#endif
  NSLog(@"------------------------");
}
