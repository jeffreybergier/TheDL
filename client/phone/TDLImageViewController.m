#import "TDLImageViewController.h"
#import "TDLDownload.h"
#import "CrossPlatform.h"

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
  [[self view] setBackgroundColor:[UIColor whiteColor]];
  
  UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] 
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                  target:self 
                                  action:@selector(dismiss)];
  [[self navigationItem] setLeftBarButtonItem:doneButton];
  [doneButton release];
  
  _scrollView = [[UIScrollView alloc] initWithFrame:[[self view] bounds]];
  [_scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
  [_scrollView setBackgroundColor:[UIColor whiteColor]];
  [_scrollView setDelegate:self];
  [_scrollView setMinimumZoomScale:1.0];
  [_scrollView setMaximumZoomScale:5.0];
  [_scrollView setShowsVerticalScrollIndicator:NO];
  [_scrollView setShowsHorizontalScrollIndicator:NO];
  
  UIImage *image = [UIImage imageWithContentsOfFile:[_download filePath]];
  if (image) {
    _imageView = [[UIImageView alloc] initWithImage:image];
    [_imageView setUserInteractionEnabled:YES];
    [_imageView setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [_scrollView setContentSize:[image size]];
    [_scrollView addSubview:_imageView];
    
    // Fit the image to the screen initially
    CGFloat widthScale = [[self view] bounds].size.width / [image size].width;
    CGFloat heightScale = [[self view] bounds].size.height / [image size].height;
    CGFloat minScale = widthScale < heightScale ? widthScale : heightScale;
    
    [_scrollView setMinimumZoomScale:minScale];
    [_scrollView setZoomScale:minScale];
    
    // Center the image initially
    [self scrollViewDidZoom:_scrollView];
    
    // Double tap to zoom
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] 
                                         initWithTarget:self 
                                         action:@selector(handleDoubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [_imageView addGestureRecognizer:doubleTap];
    [doubleTap release];
  } else {
    NSLog(@"[TDLImageViewController viewDidLoad] Failed to load image at: %@", [_download filePath]);
    
    UILabel *errorLabel = [[UILabel alloc] initWithFrame:[[self view] bounds]];
    [errorLabel setText:@"Failed to load image"];
    [errorLabel setTextAlignment:XPTextAlignmentCenter];
    [errorLabel setBackgroundColor:[UIColor whiteColor]];
    [[self view] addSubview:errorLabel];
    [errorLabel release];
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
