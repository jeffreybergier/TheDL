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

// On OS X 10.4 and 10.5, NSApplicationDelegate was not a formal protocol.
#if __MAC_OS_X_VERSION_MIN_REQUIRED >= 1060
#define XPApplicationDelegate NSApplicationDelegate
#else
@protocol XPApplicationDelegate <NSObject>
@end
#endif

typedef NSTextAlignment XPTextAlignment;
#if __MAC_OS_X_VERSION_MIN_REQUIRED >= 10110
#define XPTextAlignmentLeft NSTextAlignmentLeft
#define XPTextAlignmentCenter NSTextAlignmentCenter
#define XPTextAlignmentRight NSTextAlignmentRight
#else
#define XPTextAlignmentLeft NSLeftTextAlignment
#define XPTextAlignmentCenter NSCenterTextAlignment
#define XPTextAlignmentRight NSRightTextAlignment
#endif

#endif

/**
 * Returns the name of the current platform.
 *
 * @return A string ("iOS" or "macOS").
 */
NSString *XPGetPlatformName(void);

/**
 * A cross-platform video player view controller.
 * Uses MPMoviePlayerController on iOS 3.1 and AVPlayer on iOS 4.0+.
 */
@interface XPPlayerViewController : XPViewController {
 @private
  NSURL *_contentURL;
  id _player;      // MPMoviePlayerController or AVPlayer
  id _playerLayer; // AVPlayerLayer (iOS 4+)
}

/**
 * Initializes the player with a content URL.
 */
- (id)initWithContentURL:(NSURL *)url;

/** Starts playback. */
- (void)play;

/** Stops playback. */
- (void)stop;

@end

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
