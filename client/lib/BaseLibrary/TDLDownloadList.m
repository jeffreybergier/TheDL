#import "TDLDownloadList.h"
#import "TDLDownload.h"
#import "CrossPlatform.h"
#include <sys/xattr.h>

static NSString *const kTDLMetadataXattrName = @"com.kumasan.thedl.metadata";

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
    NSDate *date1 = nil, *date2 = nil;
    [obj1 getResourceValue:&date1 forKey:NSURLContentModificationDateKey error:nil];
    [obj2 getResourceValue:&date2 forKey:NSURLContentModificationDateKey error:nil];
    
    if (date1 && date2) {
      return [date2 compare:date1];
    } else if (date1) {
      return NSOrderedAscending;
    } else if (date2) {
      return NSOrderedDescending;
    }
    return NSOrderedSame;
  }];
  
  return sortedFiles;
}

- (TDLDownload *)getTDLDownloadForURL:(NSURL *)url {
  if (!url) return nil;
  
  const char *path = [[url path] fileSystemRepresentation];
  const char *name = [kTDLMetadataXattrName UTF8String];
  
  // 1. Get size of attribute
  ssize_t size = getxattr(path, name, NULL, 0, 0, 0);
  if (size <= 0) {
    return [[[TDLDownload alloc] init] autorelease];
  }
  
  // 2. Read attribute data
  void *buffer = malloc(size);
  if (getxattr(path, name, buffer, size, 0, 0) == size) {
    NSData *data = [NSData dataWithBytesNoCopy:buffer length:size freeWhenDone:YES];
    NSDictionary *dict = [NSPropertyListSerialization propertyListFromData:data 
                                                          mutabilityOption:NSPropertyListImmutable 
                                                                    format:NULL 
                                                          errorDescription:NULL];
    if (dict) {
      NSLog(@"[TDLDownloadList] Loaded metadata from xattr: %@", [url lastPathComponent]);
      return [[[TDLDownload alloc] initWithDictionary:dict] autorelease];
    }
  } else {
    free(buffer);
  }
  
  return [[[TDLDownload alloc] init] autorelease];
}

- (void)saveDownload:(TDLDownload *)download forURL:(NSURL *)url {
  if (!download || !url) return;
  
  NSDictionary *dict = [download dictionaryRepresentation];
  NSString *errorDesc = nil;
  NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:dict 
                                                                 format:NSPropertyListBinaryFormat_v1_0 
                                                       errorDescription:&errorDesc];
  
  if (plistData) {
    const char *path = [[url path] fileSystemRepresentation];
    const char *name = [kTDLMetadataXattrName UTF8String];
    
    NSLog(@"[TDLDownloadList] ATTEMPTING XATTR SAVE: %s", path);
    int result = setxattr(path, name, [plistData bytes], [plistData length], 0, 0);
    if (result == 0) {
      NSLog(@"[TDLDownloadList] Saved metadata to xattr: %@", [url lastPathComponent]);
    } else {
      NSLog(@"[TDLDownloadList] ERROR: Could not write xattr: %d", result);
    }
  } else {
    NSLog(@"[TDLDownloadList] ERROR: Serialization failed: %@", errorDesc);
    [errorDesc release];
  }
}

- (void)deleteFileAtURL:(NSURL *)url {
  if (!url) return;
  [[NSFileManager defaultManager] removeItemAtPath:[url path] error:nil];
}

@end
