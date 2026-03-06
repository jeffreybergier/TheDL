#import "CrossPlatform.h"

#if TARGET_OS_IPHONE
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#endif

NSString *XPGetPlatformName() {
#if TARGET_OS_IPHONE
  return @"iOS";
#else
  return @"macOS";
#endif
}

@implementation XPPlayerViewController

- (id)initWithContentURL:(NSURL *)url {
  self = [super init];
  if (self) {
    _contentURL = [url retain];
    NSLog(@"[XPPlayerViewController initWithContentURL:] URL: %@", url);
  }
  return self;
}

- (void)dealloc {
#if TARGET_OS_IPHONE
  [[NSNotificationCenter defaultCenter] removeObserver:self];
#endif
  [_contentURL release];
  [_player release];
  [_playerLayer release];
  [super dealloc];
}

#if TARGET_OS_IPHONE
- (void)loadView {
  UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  [view setBackgroundColor:[UIColor blackColor]];
  [self setView:view];
  [view release];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Verify file existence if it's a local file
  if ([_contentURL isFileURL]) {
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:[_contentURL path]]) {
      NSLog(@"[XPPlayerViewController viewDidLoad] ERROR: File does not exist at path: %@", [_contentURL path]);
    } else {
      NSDictionary *attrs = [fm attributesOfItemAtPath:[_contentURL path] error:nil];
      NSLog(@"[XPPlayerViewController viewDidLoad] File exists, size: %@", [attrs objectForKey:NSFileSize]);
    }
  }

  // Check for AVPlayer availability (iOS 4.0+)
  if (NSClassFromString(@"AVPlayer")) {
    NSLog(@"[XPPlayerViewController viewDidLoad] Using AVPlayer");
    _player = [[AVPlayer alloc] initWithURL:_contentURL];
    _playerLayer = [[AVPlayerLayer playerLayerWithPlayer:_player] retain];
    [(AVPlayerLayer *)_playerLayer setFrame:[[self view] bounds]];
    [(AVPlayerLayer *)_playerLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    [[[self view] layer] addSublayer:_playerLayer];
    
    // Add a simple tap-to-dismiss
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stop)];
    [[self view] addGestureRecognizer:tap];
    [tap release];
  } else {
    // Fallback to MPMoviePlayerController (iOS 3.1)
    NSLog(@"[XPPlayerViewController viewDidLoad] Using MPMoviePlayerController");
    _player = [[MPMoviePlayerController alloc] initWithContentURL:_contentURL];
    
    // For 3.1, we might need to add the view manually if it's not full-screen
    if ([_player respondsToSelector:@selector(view)]) {
        UIView *playerView = [_player performSelector:@selector(view)];
        [playerView setFrame:[[self view] bounds]];
        [[self view] addSubview:playerView];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerFinished:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];
  }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self play];
}
#endif

- (void)play {
  NSLog(@"[XPPlayerViewController play] Triggering playback...");
  if ([_player respondsToSelector:@selector(play)]) {
    [_player performSelector:@selector(play)];
  }
}

- (void)stop {
  NSLog(@"[XPPlayerViewController stop] Stopping playback and dismissing.");
#if TARGET_OS_IPHONE
  if ([_player respondsToSelector:@selector(pause)]) {
    [_player performSelector:@selector(pause)];
  } else if ([_player respondsToSelector:@selector(stop)]) {
    [_player performSelector:@selector(stop)];
  }
  
  if ([self respondsToSelector:@selector(presentingViewController)] && [self presentingViewController]) {
    [self dismissModalViewControllerAnimated:YES];
  } else if ([self parentViewController]) {
    [self dismissModalViewControllerAnimated:YES];
  }
#endif
}

#if TARGET_OS_IPHONE
- (void)playerFinished:(NSNotification *)note {
  NSLog(@"[XPPlayerViewController playerFinished:] Reason: %@", [[note userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey]);
  [self stop];
}
#endif

@end

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
