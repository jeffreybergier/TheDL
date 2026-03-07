#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

/**
 * An iOS-specific video player view controller.
 * Uses MPMoviePlayerController on iOS 3.1 and AVPlayer on iOS 4.0+.
 */
@interface TDLPlayerViewController : UIViewController {
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
