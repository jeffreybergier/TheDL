#import <Foundation/Foundation.h>
#include <TargetConditionals.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#define XPApplicationDelegate UIApplicationDelegate
#define XPViewController UIViewController

typedef NSTextAlignment XPTextAlignment;
#define XPTextAlignmentLeft NSTextAlignmentLeft
#define XPTextAlignmentCenter NSTextAlignmentCenter
#define XPTextAlignmentRight NSTextAlignmentRight

#else
#import <AppKit/AppKit.h>
#define XPViewController NSObject

#if __MAC_OS_X_VERSION_MIN_REQUIRED >= 1060
#define XPApplicationDelegate NSApplicationDelegate
#else
@protocol XPApplicationDelegate <NSObject>
@end
#endif

// TODO: Fix this on iOS 5 and lower
typedef NSTextAlignment XPTextAlignment;
#define XPTextAlignmentLeft NSTextAlignmentLeft
#define XPTextAlignmentCenter NSTextAlignmentCenter
#define XPTextAlignmentRight NSTextAlignmentRight

#endif

/**
 * Logs the versions of all libraries and frameworks used.
 */
void XPLogLibraryVersions(void);

@interface NSFileManager (CrossPlatform)

/**
 * Cross-platform wrapper for contentsOfDirectoryAtPath:error:
 * Falls back to directoryContentsAtPath: on legacy systems.
 */
- (NSArray *)XP_contentsOfDirectoryAtPath:(NSString *)path error:(NSError **)error;

/**
 * Cross-platform wrapper for createDirectoryAtPath:withIntermediateDirectories:attributes:error:
 * Falls back to createDirectoryAtPath:attributes: on legacy systems.
 */
- (BOOL)XP_createDirectoryAtPath:(NSString *)path 
     withIntermediateDirectories:(BOOL)createIntermediates 
                      attributes:(NSDictionary *)attributes 
                           error:(NSError **)error;

@end
