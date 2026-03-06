#import "CrossPlatform.h"

NSString *XPGetPlatformName() {
#if TARGET_OS_IPHONE
  return @"iOS";
#else
  return @"macOS";
#endif
}

@implementation NSFileManager (CrossPlatform)

- (NSArray *)XP_contentsOfDirectoryAtPath:(NSString *)path error:(NSError **)error {
#if TARGET_OS_IPHONE || __MAC_OS_X_VERSION_MIN_REQUIRED >= 1050
  return [self contentsOfDirectoryAtPath:path error:error];
#else
  return [self directoryContentsAtPath:path];
#endif
}

- (BOOL)XP_createDirectoryAtPath:(NSString *)path 
     withIntermediateDirectories:(BOOL)createIntermediates 
                      attributes:(NSDictionary *)attributes 
                           error:(NSError **)error {
#if TARGET_OS_IPHONE || __MAC_OS_X_VERSION_MIN_REQUIRED >= 1050
  return [self createDirectoryAtPath:path 
         withIntermediateDirectories:createIntermediates 
                          attributes:attributes 
                               error:error];
#else
  return [self createDirectoryAtPath:path attributes:attributes];
#endif
}

@end
