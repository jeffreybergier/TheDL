#import "TDLImageViewController.h"
#import "TDLDownload.h"
#import "CrossPlatform.h"

@implementation TDLImageViewController

- (id)initWithDownloadURL:(NSURL *)url {
  self = [super init];
  if (self) {
    _downloadURL = [url retain];
    [self setTitle:[_downloadURL lastPathComponent]];
  }
  return self;
}

- (void)dealloc {
  [_downloadURL release];
  [_scrollView release];
  [_imageView release];
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  NSLog(@"[TDLImageViewController viewDidLoad]");

  [[self view] setBackgroundColor:[UIColor whiteColor]];

  _scrollView = [[UIScrollView alloc] initWithFrame:[[self view] bounds]];
  [_scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
  [_scrollView setDelegate:self];
  [_scrollView setMinimumZoomScale:1.0];
  [_scrollView setMaximumZoomScale:5.0];
  [_scrollView setShowsHorizontalScrollIndicator:NO];
  [_scrollView setShowsVerticalScrollIndicator:NO];
  [_scrollView setBackgroundColor:[UIColor whiteColor]];
  [[self view] addSubview:_scrollView];

  // Load image from URL
  UIImage *image = [UIImage imageWithContentsOfFile:[_downloadURL path]];
  _imageView = [[UIImageView alloc] initWithImage:image];
  [_scrollView addSubview:_imageView];
  [_scrollView setContentSize:[image size]];

  UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                  target:self
                                  action:@selector(dismiss)];
  [[self navigationItem] setRightBarButtonItem:doneButton];
  [doneButton release];

  UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]
                                        initWithTarget:self
                                        action:@selector(handleDoubleTap:)];
  [doubleTap setNumberOfTapsRequired:2];
  [_scrollView addGestureRecognizer:doubleTap];
  [doubleTap release];
  
  // Center initially
  [self scrollViewDidZoom:_scrollView];
}

- (void)dismiss {
  [self dismissModalViewControllerAnimated:YES];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture {
  if ([_scrollView zoomScale] > 1.0) {
    [_scrollView setZoomScale:1.0 animated:YES];
  } else {
    CGPoint point = [gesture locationInView:_imageView];
    CGRect zoomRect = [self zoomRectForScale:2.0 withCenter:point];
    [_scrollView zoomToRect:zoomRect animated:YES];
  }
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
  CGRect zoomRect;
  zoomRect.size.height = [_scrollView frame].size.height / scale;
  zoomRect.size.width  = [_scrollView frame].size.width  / scale;
  zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
  zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
  return zoomRect;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
  return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
  CGSize boundsSize = [scrollView bounds].size;
  CGRect contentsFrame = [_imageView frame];
  
  if (contentsFrame.size.width < boundsSize.width) {
    contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0;
  } else {
    contentsFrame.origin.x = 0.0;
  }
  
  if (contentsFrame.size.height < boundsSize.height) {
    contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0;
  } else {
    contentsFrame.origin.y = 0.0;
  }
  
  [_imageView setFrame:contentsFrame];
}

@end
