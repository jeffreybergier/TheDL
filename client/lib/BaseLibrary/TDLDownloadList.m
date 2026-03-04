#import "TDLDownloadList.h"
#import "TDLDownload.h"
#include <TargetConditionals.h>

@implementation TDLDownloadList

+ (NSArray *)allDownloads {
  NSMutableArray *downloads = [NSMutableArray array];
  
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *downloadsPath = [documentsDirectory stringByAppendingPathComponent:@"Downloads"];
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  BOOL isDir = NO;
  if (![fileManager fileExistsAtPath:downloadsPath isDirectory:&isDir] || !isDir) {
    return downloads;
  }
  
  NSArray *files = nil;
#if !TARGET_OS_IPHONE && defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && __MAC_OS_X_VERSION_MIN_REQUIRED < 1050
  if ([fileManager respondsToSelector:@selector(directoryContentsAtPath:)]) {
    files = [fileManager performSelector:@selector(directoryContentsAtPath:) withObject:downloadsPath];
  }
#else
  files = [fileManager contentsOfDirectoryAtPath:downloadsPath error:nil];
#endif
  
  if (files) {
    unsigned int count = [files count];
    unsigned int i;
    for (i = 0; i < count; i++) {
      NSString *file = [files objectAtIndex:i];
      if ([[file pathExtension] isEqualToString:@"plist"]) {
        NSString *fullPath = [downloadsPath stringByAppendingPathComponent:file];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:fullPath];
        if (dict) {
          TDLDownload *download = [[TDLDownload alloc] initWithDictionary:dict];
          [downloads addObject:download];
          [download release];
        }
      }
    }
  }
  
  return downloads;
}

+ (void)__DEBUG_createFakeData {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *downloadsPath = [documentsDirectory stringByAppendingPathComponent:@"Downloads"];
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
#if !TARGET_OS_IPHONE && defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && __MAC_OS_X_VERSION_MIN_REQUIRED < 1050
  if ([fileManager respondsToSelector:@selector(createDirectoryAtPath:attributes:)]) {
    [fileManager performSelector:@selector(createDirectoryAtPath:attributes:) 
                      withObject:downloadsPath 
                      withObject:nil];
  }
#else
  [fileManager createDirectoryAtPath:downloadsPath withIntermediateDirectories:YES attributes:nil error:nil];
#endif
  
  NSArray *fakeNames = [NSArray arrayWithObjects:@"Debian DVD", @"Tiger.dmg", @"Music.mp3", nil];
  unsigned int i;
  for (i = 0; i < [fakeNames count]; i++) {
    NSString *name = [fakeNames objectAtIndex:i];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          name, @"displayName",
                          @"/tmp/fake", @"filePath",
                          @"application/octet-stream", @"contentType",
                          @"http://example.com/fake", @"requestURL",
                          [NSNumber numberWithLongLong:1024 * (i + 1)], @"actualSize",
                          [NSNumber numberWithLongLong:2048 * (i + 1)], @"contentSize", nil];
    
    NSString *plistName = [NSString stringWithFormat:@"debug_%d.plist", i];
    NSString *fullPath = [downloadsPath stringByAppendingPathComponent:plistName];
    [dict writeToFile:fullPath atomically:YES];
  }
}

@end
