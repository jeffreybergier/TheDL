#import "TDLTextViewController.h"
#import "TDLDownload.h"

@implementation TDLTextViewController

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
  [_textView release];
  [super dealloc];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  _textView = [[UITextView alloc] initWithFrame:[[self view] bounds]];
  [_textView setEditable:NO];
  [_textView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
  [_textView setFont:[UIFont fontWithName:@"Courier" size:12.0]];
  [[self view] addSubview:_textView];
  
  UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] 
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                  target:self 
                                  action:@selector(dismiss)];
  [[self navigationItem] setRightBarButtonItem:doneButton];
  [doneButton release];
  
  [self loadText];
}

- (void)dismiss {
  [self dismissModalViewControllerAnimated:YES];
}

- (void)loadText {
  NSError *error = nil;
  NSString *content = [NSString stringWithContentsOfFile:[_downloadURL path] 
                                                encoding:NSUTF8StringEncoding 
                                                   error:&error];
  if (content) {
    [_textView setText:content];
  } else {
    [_textView setText:[NSString stringWithFormat:@"Error loading text: %@", [error localizedDescription]]];
  }
}

@end
