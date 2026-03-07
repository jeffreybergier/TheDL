#import "TDLPlayerViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation TDLPlayerViewController

- (id)initWithContentURL:(NSURL *)url {
  self = [super init];
  if (self) {
    _contentURL = [url retain];
    
    // Check if AVPlayer is available (iOS 4.0+)
    if (NSClassFromString(@"AVPlayer")) {
      _player = [[AVPlayer alloc] initWithURL:_contentURL];
      _playerLayer = [[AVPlayerLayer playerLayerWithPlayer:_player] retain];
    } else {
      // Fallback to MPMoviePlayerController (iOS 3.1+)
      _player = [[MPMoviePlayerController alloc] initWithContentURL:_contentURL];
    }
  }
  return self;
}

- (void)dealloc {
  [_contentURL release];
  [_player release];
  [_playerLayer release];
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [[self view] setBackgroundColor:[UIColor blackColor]];
  
  if (_playerLayer) {
    [(AVPlayerLayer *)_playerLayer setFrame:[[self view] bounds]];
    [[[self view] layer] addSublayer:_playerLayer];
  } else if ([_player respondsToSelector:@selector(view)]) {
    UIView *playerView = [_player performSelector:@selector(view)];
    [playerView setFrame:[[self view] bounds]];
    [playerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [[self view] addSubview:playerView];
  }
}

- (void)play {
  NSLog(@"[TDLPlayerViewController play] %@", _contentURL);
  if ([_player respondsToSelector:@selector(play)]) {
    [_player performSelector:@selector(play)];
  }
}

- (void)stop {
  NSLog(@"[TDLPlayerViewController stop] Stopping playback.");
  if ([_player respondsToSelector:@selector(pause)]) {
    [_player performSelector:@selector(pause)];
  } else if ([_player respondsToSelector:@selector(stop)]) {
    [_player performSelector:@selector(stop)];
  }
}

@end
