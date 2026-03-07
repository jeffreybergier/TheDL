#import <Foundation/Foundation.h>

@class TDLDownload;

/**
 * Represents an in-progress download task.
 */
@interface TDLDownloadTask : NSObject {
 @private
  NSURL *_targetFileURL;
  TDLDownload *_metadata;
  NSURLConnection *_connection;
}

- (id)initWithTargetURL:(NSURL *)fileURL metadata:(TDLDownload *)download;

- (NSURL *)targetFileURL;
- (TDLDownload *)metadata;

- (NSURLConnection *)connection;
- (void)setConnection:(NSURLConnection *)connection;

@end
