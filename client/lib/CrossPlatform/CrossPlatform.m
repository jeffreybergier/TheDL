#import "CrossPlatform.h"
#import "XPObject.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

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
  NSLog(@"[CURL] Disabled");
#endif
  NSLog(@"------------------------");
}

#if TARGET_OS_IPHONE
@implementation XPViewController
- (void)viewDidLoad {
  [super viewDidLoad];
  NSLog(@"[XPViewController viewDidLoad]");
}
@end
#endif

@implementation NSFileManager (CrossPlatform)

- (BOOL)XP_createDirectoryAtPath:(NSString *)path 
     withIntermediateDirectories:(BOOL)createIntermediates 
                      attributes:(NSDictionary *)attributes 
                           error:(NSError **)error {
#if TARGET_OS_IPHONE
  return [self createDirectoryAtPath:path withIntermediateDirectories:createIntermediates attributes:attributes error:error];
#else
  // 10.4 Tiger compatibility
  if (createIntermediates) {
    // Basic implementation for 10.4
    NSArray *components = [path pathComponents];
    NSString *currentPath = @"";
    NSEnumerator *enumerator = [components objectEnumerator];
    NSString *component;
    while ((component = [enumerator nextObject])) {
      currentPath = [currentPath stringByAppendingPathComponent:component];
      if (![self fileExistsAtPath:currentPath]) {
        if (![self createDirectoryAtPath:currentPath attributes:attributes]) {
          return NO;
        }
      }
    }
    return YES;
  } else {
    return [self createDirectoryAtPath:path attributes:attributes];
  }
#endif
}

- (NSArray *)XP_contentsOfDirectoryAtPath:(NSString *)path error:(NSError **)error {
#if TARGET_OS_IPHONE
  return [self contentsOfDirectoryAtPath:path error:error];
#else
  // 10.4 Tiger compatibility
  return [self directoryContentsAtPath:path];
#endif
}

@end
