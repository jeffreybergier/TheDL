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
  NSString *content = nil;
  
  // Try UTF-8 first
  content = [NSString stringWithContentsOfFile:[_downloadURL path] 
                                      encoding:NSUTF8StringEncoding 
                                         error:&error];
  
  // Fallback to ASCII/Windows-1252 if UTF-8 fails
  if (!content) {
    content = [NSString stringWithContentsOfFile:[_downloadURL path] 
                                        encoding:NSWindowsCP1252StringEncoding 
                                           error:nil];
  }
  
  if (content) {
    [_textView setText:content];
  } else {
    NSString *errorMsg = [error localizedDescription] ? [error localizedDescription] : @"Unknown encoding error";
    [_textView setText:[NSString stringWithFormat:@"Error loading text: %@", errorMsg]];
  }
}

@end
