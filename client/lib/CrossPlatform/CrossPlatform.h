#import <Foundation/Foundation.h>
#include <TargetConditionals.h>

// MARK: Import Appropriate Kit
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif

// MARK: Log Library Versions
/**
 * Logs the versions of all libraries and frameworks used.
 */
void XPLogLibraryVersions(void);

// MARK: Fix OS X "Modern" Protocols
#if __MAC_OS_X_VERSION_MIN_REQUIRED >= 1060
#define XPApplicationDelegate NSApplicationDelegate
#else
@protocol XPApplicationDelegate <NSObject>
@end
#endif

// MARK: Fix NSTextAlignment symbol issues

#if defined(TARGET_OS_IPHONE) && __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
#define XPTextAlignment          UITextAlignment
#define XPTextAlignmentLeft      (NSInteger)UITextAlignmentLeft
#define XPTextAlignmentRight     (NSInteger)UITextAlignmentRight
#define XPTextAlignmentCenter    (NSInteger)UITextAlignmentCenter
#define XPTextAlignmentJustified (NSInteger)UITextAlignmentLeft
#define XPTextAlignmentNatural   (NSInteger)UITextAlignmentLeft
#elif __MAC_OS_X_VERSION_MIN_REQUIRED >= 1080
#define XPTextAlignment          NSTextAlignment
#define XPTextAlignmentLeft      NSTextAlignmentLeft
#define XPTextAlignmentRight     NSTextAlignmentRight
#define XPTextAlignmentCenter    NSTextAlignmentCenter
#define XPTextAlignmentJustified NSTextAlignmentJustified
#define XPTextAlignmentNatural   NSTextAlignmentNatural
#else
#define XPTextAlignment          NSInteger
#define XPTextAlignmentLeft      NSLeftTextAlignment
#define XPTextAlignmentRight     NSRightTextAlignment
#define XPTextAlignmentCenter    NSCenterTextAlignment
#define XPTextAlignmentJustified NSJustifiedTextAlignment
#define XPTextAlignmentNatural   NSNaturalTextAlignment
#endif

