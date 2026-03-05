#import <Foundation/Foundation.h>
#include <TargetConditionals.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#define XPApplicationDelegate UIApplicationDelegate
#else
#import <AppKit/AppKit.h>

// On OS X 10.4 and 10.5, NSApplicationDelegate was not a formal protocol.
#if defined(__MAC_10_6)
#define XPApplicationDelegate NSApplicationDelegate
#else
@protocol XPApplicationDelegate <NSObject>
@end
#endif

#endif

/**
 * Returns the name of the current platform.
 *
 * @return A string ("iOS" or "macOS").
 */
NSString *XPGetPlatformName(void);
