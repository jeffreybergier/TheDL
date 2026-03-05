#import "TDLDownloadList.h"
#import "TDLDownload.h"

@implementation TDLDownloadList

+ (NSArray *)allDownloads {
  NSLog(@"[TDLDownloadList allDownloads] Start");
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
  // TODO: replace with contentsOfDirectoryAtPath:error: for 10.5+ / iOS 2.0+
  files = [fileManager directoryContentsAtPath:downloadsPath];
  
  if (files) {
    unsigned int count = [files count];
    unsigned int i;
    for (i = 0; i < count; i++) {
      NSString *file = [files objectAtIndex:i];
      if ([[file pathExtension] isEqualToString:@"plist"]) {
        NSString *fullPath = [downloadsPath stringByAppendingPathComponent:file];
        TDLDownload *download = [[TDLDownload alloc] initWithURL:[NSURL fileURLWithPath:fullPath] options:0 error:nil];
        if (download) {
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
  // TODO: replace with createDirectoryAtPath:withIntermediateDirectories:attributes:error: for 10.5+ / iOS 2.0+
  [fileManager createDirectoryAtPath:downloadsPath attributes:nil];
  
  NSArray *fakeNames = [NSArray arrayWithObjects:@"Debian DVD", @"Tiger.dmg", @"Music.mp3", nil];
  unsigned int i;
  for (i = 0; i < [fakeNames count]; i++) {
    NSString *name = [fakeNames objectAtIndex:i];
    TDLDownload *download = [[TDLDownload alloc] init];
    [download setDisplayName:name];
    [download setFilePath:@"/tmp/fake"];
    [download setContentType:@"application/octet-stream"];
    [download setActualSize:1024 * (i + 1)];
    [download setContentSize:2048 * (i + 1)];
    
    NSString *plistName = [NSString stringWithFormat:@"debug_%d.plist", i];
    NSString *fullPath = [downloadsPath stringByAppendingPathComponent:plistName];
    [[download dictionaryRepresentation] writeToFile:fullPath atomically:YES];
    [download release];
  }
}

@end
