#import "TDLDownloadList.h"
#import "TDLDownload.h"
#import "TDLServiceManager.h"
#import "CrossPlatform.h"
#include <sys/xattr.h>

NSString *const TDLDownloadListUpdatedNotification = @"TDLDownloadListUpdatedNotification";

static NSString *const kTDLMetadataXattrName = @"com.kumasan.thedl.metadata";

@implementation TDLDownloadList

- (id)initWithDownloadsDirectoryURL:(NSURL *)url {
  self = [super init];
  if (self) {
    _downloadsDirectoryURL = [url retain];
    
    // Ensure directory exists
    [[NSFileManager defaultManager] createDirectoryAtPath:[_downloadsDirectoryURL path] 
                              withIntermediateDirectories:YES 
                                               attributes:nil 
                                                    error:NULL];
    
    // Initialize services owned by this list
    _serviceManager = [[TDLServiceManager alloc] initWithDownloadList:self];
  }
  return self;
}

- (void)dealloc {
  [_serviceManager release];
  [_downloadsDirectoryURL release];
  [super dealloc];
}

- (NSURL *)downloadsDirectoryURL {
  return _downloadsDirectoryURL;
}

- (TDLServiceManager *)serviceManager {
  return _serviceManager;
}

+ (NSDictionary *)sampleURLs {
  return [NSDictionary dictionaryWithObjectsAndKeys:
    @"https://platform.theverge.com/wp-content/uploads/sites/2/2026/03/Installer-118.png?quality=90&strip=all&crop=0%2C0%2C100%2C100&w=1440", @"The Verge (Image)",
    @"https://theverge.com/rss/index.xml", @"The Verge (RSS)",
    @"https://www.shutterstock.com/shutterstock/videos/3462297387/preview/stock-footage-close-up-portrait-shot-of-a-beautiful-confident-fitness-girl-in-black-athletic-top-and-shorts.mp4", @"Shutterstock (Video)",
    @"https://wsb.hostdon.ne.jp/sgm234/cache/media_attachments/files/116/183/417/604/082/991/original/03597a642f0ecfd1.jpeg", @"Hostdon (Image)",
    @"https://wsb.hostdon.ne.jp/sgm234/cache/media_attachments/files/116/184/611/983/940/903/original/dee8c16db13df154.mp4", @"Hostdon (Video)",
    @"https://feeds.macrumors.com/MacRumors-All", @"MacRumors (Text)",
    nil];
}

- (NSArray *)allDownloads {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  
  // Pre-fetch modification date and file size for performance
  NSArray *keys = [NSArray arrayWithObjects:NSURLContentModificationDateKey, NSURLFileSizeKey, nil];
  
  NSError *error = nil;
  NSArray *files = [fileManager contentsOfDirectoryAtURL:_downloadsDirectoryURL 
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

- (NSURL *)targetURLForDownloadURL:(NSURL *)url {
  if (!url) return nil;
  
  NSString *lastComponent = [[url path] lastPathComponent];
  if (!lastComponent || [lastComponent length] == 0) {
    lastComponent = @"download.data";
  }
  
  // Prepend host to filename if available
  if ([url host]) {
    lastComponent = [NSString stringWithFormat:@"%@-%@", [url host], lastComponent];
  }
  
  NSString *downloadsDir = [_downloadsDirectoryURL path];
  NSString *dataPath = [downloadsDir stringByAppendingPathComponent:lastComponent];

  // Deduplicate using " (2)" format
  if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
    NSString *base = [lastComponent stringByDeletingPathExtension];
    NSString *ext = [lastComponent pathExtension];
    int counter = 2;
    while ([[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
      NSString *newName = [NSString stringWithFormat:@"%@ (%d)", base, counter];
      if ([ext length] > 0) {
        newName = [newName stringByAppendingPathExtension:ext];
      }
      dataPath = [downloadsDir stringByAppendingPathComponent:newName];
      counter++;
    }
  }
  
  return [NSURL fileURLWithPath:dataPath];
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
      
      // Post notification on main thread for UI
      dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"[TDLDownloadList] Posting TDLDownloadListUpdatedNotification for %@", [url path]);
        [[NSNotificationCenter defaultCenter] postNotificationName:TDLDownloadListUpdatedNotification 
                                                            object:self 
                                                          userInfo:[NSDictionary dictionaryWithObject:url forKey:@"URL"]];
      });
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
