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
  return self;
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
  NSURL *downloadsURL = [NSURL fileURLWithPath:downloadsPath];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  
  // Pre-fetch modification date and file size for performance
  NSArray *keys = [NSArray arrayWithObjects:NSURLContentModificationDateKey, NSURLFileSizeKey, nil];
  
  NSError *error = nil;
  NSArray *files = [fileManager contentsOfDirectoryAtURL:downloadsURL 
                              includingPropertiesForKeys:keys 
                                                 options:NSDirectoryEnumerationSkipsHiddenFiles 
                                                   error:&error];
  
  if (!files) {
    NSLog(@"[TDLDownloadList] ERROR: Could not enumerate directory: %@", [error localizedDescription]);
    return [NSArray array];
  }
  
  // Sort using the pre-fetched modification date
  NSArray *sortedFiles = [files sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    NSDate *date1, *date2;
    [obj1 getResourceValue:&date1 forKey:NSURLContentModificationDateKey error:nil];
    [obj2 getResourceValue:&date2 forKey:NSURLContentModificationDateKey error:nil];
    
    // Newest first
    return [date2 compare:date1];
  }];
  
  return sortedFiles;
}

- (TDLDownload *)getTDLDownloadForURL:(NSURL *)url {
  if (!url) return nil;
  
  // Retro Trick: Access the resource fork via the ..namedfork/rsrc path
  NSString *resourcePath = [[url path] stringByAppendingPathComponent:@"..namedfork/rsrc"];
  
  NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:resourcePath];
  if (dict) {
    return [[[TDLDownload alloc] initWithDictionary:dict] autorelease];
  }
  
  // Fallback: Check if it's a valid download but has no metadata yet
  return [[[TDLDownload alloc] init] autorelease];
}

- (void)saveDownload:(TDLDownload *)download forURL:(NSURL *)url {
  if (!download || !url) return;
  
  // Retro Trick: Access the resource fork via the ..namedfork/rsrc path
  NSString *resourcePath = [[url path] stringByAppendingPathComponent:@"..namedfork/rsrc"];
  
  // Note: writeToFile:atomically: YES fails on named forks because it can't rename a temp file into a fork.
  // We must use NSData's non-atomic write or writeToURL.
  NSDictionary *dict = [download dictionaryRepresentation];
  NSString *errorDesc = nil;
  NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:dict 
                                                                 format:NSPropertyListBinaryFormat_v1_0 
                                                       errorDescription:&errorDesc];
  
  if (plistData) {
    BOOL success = [plistData writeToFile:resourcePath atomically:NO];
    if (!success) {
      NSLog(@"[TDLDownloadList] ERROR: Could not write plist data to resource fork at %@", resourcePath);
    }
  } else {
    NSLog(@"[TDLDownloadList] ERROR: Could not serialize metadata: %@", errorDesc);
    [errorDesc release];
  }
}

- (void)deleteFileAtURL:(NSURL *)url {
  if (!url) return;
  [[NSFileManager defaultManager] removeItemAtPath:[url path] error:nil];
}

@end
