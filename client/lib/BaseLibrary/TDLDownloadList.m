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

+ (NSString *)downloadsDirectory {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  return [documentsDirectory stringByAppendingPathComponent:@"Downloads"];
}

- (NSString *)downloadsDirectory {
  return [TDLDownloadList downloadsDirectory];
}

- (void)loadDownloadsFromDisk {
  [_downloadCache removeAllObjects];
  
  NSString *downloadsPath = [TDLDownloadList downloadsDirectory];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  
  NSLog(@"[TDLDownloadList] loadDownloadsFromDisk: path=%@", downloadsPath);
  
  BOOL isDir = NO;
  if (![fileManager fileExistsAtPath:downloadsPath isDirectory:&isDir] || !isDir) {
    return;
  }
  
  NSArray *files = [fileManager contentsOfDirectoryAtPath:downloadsPath error:nil];
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
  NSLog(@"[TDLDownloadList] loadDownloadsFromDisk: loaded %lu objects", (unsigned long)[_downloadCache count]);
}

- (NSArray *)allDownloads {
  return [_downloadCache allValues];
}

- (TDLDownload *)downloadWithUdid:(NSString *)udid {
  return [_downloadCache objectForKey:udid];
}

- (TDLDownload *)createDownload {
  NSString *rawUdid = [[NSProcessInfo processInfo] globallyUniqueString];
  // Make it a bit cleaner by stripping dashes and taking a reasonable length
  NSString *udid = [[rawUdid stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
  if ([udid length] > 12) {
    udid = [udid substringToIndex:12];
  }
  
  TDLDownload *download = [[TDLDownload alloc] init];
  [download setUdid:udid];
  
  [_downloadCache setObject:download forKey:udid];
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
  
  NSLog(@"[TDLDownloadList] deleteDownload: %@", [download udid]);
  
  // Delete Plist
  NSString *plistName = [[download udid] stringByAppendingPathExtension:@"plist"];
  NSString *plistPath = [downloadsPath stringByAppendingPathComponent:plistName];
  [fileManager removeItemAtPath:plistPath error:nil];
  
  // Delete Data File
  if ([download filePath]) {
    NSLog(@"[TDLDownloadList] Removing data file: %@", [download filePath]);
    [fileManager removeItemAtPath:[download filePath] error:nil];
  }
  
  [_downloadCache removeObjectForKey:[download udid]];
}

@end
