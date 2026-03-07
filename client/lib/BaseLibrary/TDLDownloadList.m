#import "TDLDownloadList.h"
#import "TDLDownload.h"
#import "CrossPlatform.h"

@implementation TDLDownloadList

+ (TDLDownloadList *)sharedList {
  static TDLDownloadList *sharedInstance = nil;
  if (!sharedInstance) {
    sharedInstance = [[TDLDownloadList alloc] init];
  }
  return sharedInstance;
}

- (id)init {
  self = [super init];
  if (self) {
    _downloadCache = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)dealloc {
  [_downloadCache release];
  [super dealloc];
}

+ (NSString *)downloadsDirectory {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  return [documentsDirectory stringByAppendingPathComponent:@"Downloads"];
}

- (NSString *)downloadsDirectory {
  return [TDLDownloadList downloadsDirectory];
}

- (NSArray *)allDownloads {
  NSString *downloadsPath = [TDLDownloadList downloadsDirectory];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  
  BOOL isDir = NO;
  if (![fileManager fileExistsAtPath:downloadsPath isDirectory:&isDir] || !isDir) {
    return [NSArray array];
  }
  
  NSArray *files = [fileManager contentsOfDirectoryAtPath:downloadsPath error:nil];
  if (!files) return [NSArray array];
  
  NSMutableArray *plistUrls = [NSMutableArray array];
  NSEnumerator *e = [files objectEnumerator];
  NSString *file;
  while ((file = [e nextObject])) {
    if ([[file pathExtension] isEqualToString:@"plist"]) {
      NSURL *url = [NSURL fileURLWithPath:[downloadsPath stringByAppendingPathComponent:file]];
      [plistUrls addObject:url];
    }
  }
  
  // Sort by modification date
  [plistUrls sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    NSURL *url1 = (NSURL *)obj1;
    NSURL *url2 = (NSURL *)obj2;
    
    NSDictionary *attr1 = [[NSFileManager defaultManager] attributesOfItemAtPath:[url1 path] error:nil];
    NSDictionary *attr2 = [[NSFileManager defaultManager] attributesOfItemAtPath:[url2 path] error:nil];
    
    NSDate *date1 = [attr1 fileModificationDate];
    NSDate *date2 = [attr2 fileModificationDate];
    
    // Decending order (newest first)
    return [date2 compare:date1];
  }];
  
  return plistUrls;
}

- (TDLDownload *)getTDLDownloadForURL:(NSURL *)url {
  if (!url) return nil;
  
  NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[url path]];
  if (dict) {
    return [[[TDLDownload alloc] initWithDictionary:dict] autorelease];
  }
  return nil;
}

- (NSData *)getDataForURL:(NSURL *)url {
  TDLDownload *download = [self getTDLDownloadForURL:url];
  if (download && [download filePath]) {
    return [NSData dataWithContentsOfFile:[download filePath]];
  }
  return nil;
}

- (TDLDownload *)createDownload {
  NSString *rawUdid = [[NSProcessInfo processInfo] globallyUniqueString];
  NSString *udid = [[rawUdid stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
  if ([udid length] > 12) {
    udid = [udid substringToIndex:12];
  }
  
  TDLDownload *download = [[TDLDownload alloc] init];
  [download setUdid:udid];
  
  // Cache it temporarily if needed, but we mainly rely on disk now
  [self saveDownload:download];
  
  return [download autorelease];
}

- (void)saveDownload:(TDLDownload *)download {
  if (![download udid]) return;
  
  NSString *downloadsPath = [TDLDownloadList downloadsDirectory];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  
  [fileManager createDirectoryAtPath:downloadsPath 
         withIntermediateDirectories:YES 
                          attributes:nil 
                               error:nil];
  
  NSString *plistName = [[download udid] stringByAppendingPathExtension:@"plist"];
  NSString *fullPath = [downloadsPath stringByAppendingPathComponent:plistName];
  
  [[download dictionaryRepresentation] writeToFile:fullPath atomically:YES];
}

- (void)deleteDownload:(TDLDownload *)download {
  if (![download udid]) return;
  
  NSString *downloadsPath = [TDLDownloadList downloadsDirectory];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  
  // Delete Plist
  NSString *plistName = [[download udid] stringByAppendingPathExtension:@"plist"];
  NSString *plistPath = [downloadsPath stringByAppendingPathComponent:plistName];
  [fileManager removeItemAtPath:plistPath error:nil];
  
  // Delete Data File
  if ([download filePath]) {
    [fileManager removeItemAtPath:[download filePath] error:nil];
  }
}

@end
