#import "TDLImageViewController.h"
#import "TDLDownload.h"

@implementation TDLImageViewController

- (id)initWithDownload:(TDLDownload *)download {
  self = [super init];
  if (self) {
    _download = [download retain];
    [self setTitle:[_download displayName]];
  }
  return self;
}

- (void)dealloc {
  [_download release];
  [_scrollView release];
  [_imageView release];
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [[self view] setBackgroundColor:[UIColor blackColor]];
  
  UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] 
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                  target:self 
                                  action:@selector(dismiss)];
  [[self navigationItem] setLeftBarButtonItem:doneButton];
  [doneButton release];
  
  _scrollView = [[UIScrollView alloc] initWithFrame:[[self view] bounds]];
  [_scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
  [_scrollView setBackgroundColor:[UIColor blackColor]];
  [_scrollView setDelegate:self];
  [_scrollView setMinimumZoomScale:1.0];
  [_scrollView setMaximumZoomScale:5.0];
  [_scrollView setShowsVerticalScrollIndicator:NO];
  [_scrollView setShowsHorizontalScrollIndicator:NO];
  
  UIImage *image = [UIImage imageWithContentsOfFile:[_download filePath]];
  if (image) {
    _imageView = [[UIImageView alloc] initWithImage:image];
    [_imageView setUserInteractionEnabled:YES];
    [_scrollView setContentSize:[image size]];
    [_scrollView addSubview:_imageView];
    
    // Fit the image to the screen initially if it's larger
    CGFloat widthScale = [[self view] bounds].size.width / [image size].width;
    CGFloat heightScale = [[self view] bounds].size.height / [image size].height;
    CGFloat minScale = widthScale < heightScale ? widthScale : heightScale;
    
    if (minScale < 1.0) {
      [_scrollView setMinimumZoomScale:minScale];
      [_scrollView setZoomScale:minScale];
    }
    
    // Double tap to zoom
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] 
                                         initWithTarget:self 
                                         action:@selector(handleDoubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [_imageView addGestureRecognizer:doubleTap];
    [doubleTap release];
  } else {
    NSLog(@"[TDLImageViewController viewDidLoad] Failed to load image at: %@", [_download filePath]);
  }
  
  [[self view] addSubview:_scrollView];
}

- (void)dismiss {
  [self dismissModalViewControllerAnimated:YES];
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gesture {
  if ([_scrollView zoomScale] > [_scrollView minimumZoomScale]) {
    [_scrollView setZoomScale:[_scrollView minimumZoomScale] animated:YES];
  } else {
    // Zoom into the point tapped
    CGPoint tapPoint = [gesture locationInView:_imageView];
    CGRect zoomRect = CGRectMake(tapPoint.x - 50, tapPoint.y - 50, 100, 100);
    [_scrollView zoomToRect:zoomRect animated:YES];
  }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
  return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
  // Center the image as it zooms
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
