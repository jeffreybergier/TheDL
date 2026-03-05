#import "TDLDownloadList.h"
#import "TDLDownload.h"
#include <TargetConditionals.h>

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
  NSString *downloadsPath = [self downloadsDirectory];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  
  BOOL isDir = NO;
  if (![fileManager fileExistsAtPath:downloadsPath isDirectory:&isDir] || !isDir) {
    return;
  }
  
  NSArray *files = [fileManager contentsOfDirectoryAtPath:downloadsPath error:nil];
  if (files) {
    unsigned int i;
    for (i = 0; i < [files count]; i++) {
      NSString *file = [files objectAtIndex:i];
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
  // Sort by name or date if needed, for now just return all
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
  [fileManager createDirectoryAtPath:downloadsPath withIntermediateDirectories:YES attributes:nil error:nil];
  
  NSString *plistName = [[download udid] stringByAppendingPathExtension:@"plist"];
  NSString *fullPath = [downloadsPath stringByAppendingPathComponent:plistName];
  
  [[download dictionaryRepresentation] writeToFile:fullPath atomically:YES];
}

+ (void)__DEBUG_createFakeData {
  TDLDownloadList *list = [TDLDownloadList sharedList];
  NSArray *fakeNames = [NSArray arrayWithObjects:@"Debian DVD", @"Tiger.dmg", @"Music.mp3", nil];
  unsigned int i;
  for (i = 0; i < [fakeNames count]; i++) {
    TDLDownload *download = [list createDownload];
    [download setDisplayName:[fakeNames objectAtIndex:i]];
    [download setFilePath:@"/tmp/fake"];
    [download setContentType:@"application/octet-stream"];
    [download setActualSize:1024 * (i + 1)];
    [download setContentSize:2048 * (i + 1)];
    [download setState:TDLDownloadStateFinished];
    [list saveDownload:download];
  }
}

@end
