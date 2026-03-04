#import "TDLDownloadList.h"
#import "TDLDownload.h"

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
  // contentsOfDirectoryAtPath:error: is 10.5+ and iOS 2.0+
  // Since we target 10.4, we should use directoryContentsAtPath: for the Neko build
#if !TARGET_OS_IPHONE && (defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && __MAC_OS_X_VERSION_MIN_REQUIRED < 1050)
  files = [fileManager directoryContentsAtPath:downloadsPath];
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
  [fileManager createDirectoryAtPath:downloadsPath withIntermediateDirectories:YES attributes:nil error:nil];
  
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
