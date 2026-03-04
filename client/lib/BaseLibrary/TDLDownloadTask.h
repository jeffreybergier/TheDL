#import <Foundation/Foundation.h>

typedef enum {
  TDLDownloadTaskStateRunning,
  TDLDownloadTaskStateFinished,
  TDLDownloadTaskStateFailed
} TDLDownloadTaskState;

/**
 * Represents an active or completed download task.
 */
@interface TDLDownloadTask : NSObject {
 @private
  NSURL *_url;
  TDLDownloadTaskState _state;
  NSMutableData *_accumulatedData;
  NSString *_errorMessage;
  NSString *_suggestedFilename;
  NSString *_contentType;
}

- (id)initWithURL:(NSURL *)url;

- (NSURL *)url;
- (TDLDownloadTaskState)state;
- (void)setState:(TDLDownloadTaskState)state;

- (NSMutableData *)accumulatedData;
- (NSString *)errorMessage;
- (void)setErrorMessage:(NSString *)error;

- (NSString *)suggestedFilename;
- (void)setSuggestedFilename:(NSString *)filename;

- (NSString *)contentType;
- (void)setContentType:(NSString *)type;

@end
