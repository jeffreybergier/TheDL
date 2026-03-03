#import "TDLDownloadList.h"
#import "TDLDownload.h"

@implementation TDLDownloadList

+ (NSArray *)allDownloads {
  NSMutableArray *downloads = [NSMutableArray array];
  
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSError *error = nil;
  NSArray *files = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:&error];
  
  if (!error) {
    for (NSString *file in files) {
      // Check if it looks like a directory
      NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:file];
      BOOL isDirectory = NO;
      if ([fileManager fileExistsAtPath:fullPath isDirectory:&isDirectory] && isDirectory) {
        NSURL *url = [NSURL fileURLWithPath:fullPath];
        TDLDownload *download = [[TDLDownload alloc] initWithURL:url options:0 error:nil];
        if (download && [download filename]) {
          [downloads addObject:download];
        }
        [download release];
      }
    }
  }
  
  return downloads;
}

@end
