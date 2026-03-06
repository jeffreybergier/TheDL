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
    [self loadDownloadsFromDisk];
  }
  return self;
}

- (void)dealloc {
  [_downloadCache release];
  [super dealloc];
}

- (NSString *)downloadsDirectory {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  return [documentsDirectory stringByAppendingPathComponent:@"Downloads"];
}

- (void)loadDownloadsFromDisk {
  [_downloadCache removeAllObjects];
  
  NSString *downloadsPath = [self downloadsDirectory];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  
  BOOL isDir = NO;
  if (![fileManager fileExistsAtPath:downloadsPath isDirectory:&isDir] || !isDir) {
    return;
  }
  
  // TODO: replace with contentsOfDirectoryAtPath:error: for 10.5+ / iOS 2.0+
  NSArray *files = [fileManager XP_contentsOfDirectoryAtPath:downloadsPath error:nil];
  if (files) {
    NSEnumerator *e = [files objectEnumerator];
    NSString *file;
    while ((file = [e nextObject])) {
      if ([[file pathExtension] isEqualToString:@"plist"]) {
        NSString *fullPath = [downloadsPath stringByAppendingPathComponent:file];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:fullPath];
        if (dict) {
          TDLDownload *download = [[TDLDownload alloc] initWithDictionary:dict];
          if ([download udid]) {
            [_downloadCache setObject:download forKey:[download udid]];
          }
          [download release];
        }
      }
    }
  }
}

- (NSArray *)allDownloads {
  return [_downloadCache allValues];
}

- (TDLDownload *)downloadWithUdid:(NSString *)udid {
  return [_downloadCache objectForKey:udid];
}

- (TDLDownload *)createDownload {
  NSString *udid = [[NSProcessInfo processInfo] globallyUniqueString];
  TDLDownload *download = [[TDLDownload alloc] init];
  [download setUdid:udid];
  
  [_downloadCache setObject:download forKey:udid];
  [self saveDownload:download];
  
  return [download autorelease];
}

- (void)saveDownload:(TDLDownload *)download {
  if (![download udid]) return;
  
  NSString *downloadsPath = [self downloadsDirectory];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  
  // TODO: replace with createDirectoryAtPath:withIntermediateDirectories:attributes:error: for 10.5+ / iOS 2.0+
  [fileManager XP_createDirectoryAtPath:downloadsPath 
            withIntermediateDirectories:YES 
                             attributes:nil 
                                  error:nil];
  
  NSString *plistName = [[download udid] stringByAppendingPathExtension:@"plist"];
  NSString *fullPath = [downloadsPath stringByAppendingPathComponent:plistName];
  
  [[download dictionaryRepresentation] writeToFile:fullPath atomically:YES];
}

@end
