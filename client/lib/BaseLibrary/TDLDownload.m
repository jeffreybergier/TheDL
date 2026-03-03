#import "TDLDownload.h"

static NSString *const kMetadataFileName = @"metadata.plist";
static NSString *const kDataFileName = @"data";
static NSString *const kFilenameKey = @"filename";
static NSString *const kContentTypeKey = @"contentType";

@implementation TDLDownload

- (id)initWithData:(NSData *)data 
          filename:(NSString *)filename 
       contentType:(NSString *)contentType {
  self = [super initDirectoryWithFileWrappers:nil];
  if (self) {
    _filename = [filename copy];
    _contentType = [contentType copy];
    
    // Create data wrapper
    NSFileWrapper *dataWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:data];
    [dataWrapper setPreferredFilename:kDataFileName];
    [self addFileWrapper:dataWrapper];
    [dataWrapper release];
    
    // Create metadata wrapper
    NSDictionary *metadata = [NSDictionary dictionaryWithObjectsAndKeys:
                              _filename, kFilenameKey,
                              _contentType, kContentTypeKey, nil];
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:metadata
                                                                   format:NSPropertyListBinaryFormat_v1_0
                                                         errorDescription:nil];
    NSFileWrapper *metadataWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:plistData];
    [metadataWrapper setPreferredFilename:kMetadataFileName];
    [self addFileWrapper:metadataWrapper];
    [metadataWrapper release];
  }
  return self;
}

// Using NSUInteger instead of NSFileWrapperReadingOptions for 10.4 compatibility
- (id)initWithURL:(NSURL *)url options:(NSUInteger)options error:(NSError **)outError {
#if !TARGET_OS_IPHONE && (defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && __MAC_OS_X_VERSION_MIN_REQUIRED < 1060)
  // Fallback for 10.4/10.5
  self = [super initWithPath:[url path]];
#else
  self = [super initWithURL:url options:options error:outError];
#endif
  if (self) {
    NSDictionary *wrappers = [self fileWrappers];
    NSFileWrapper *metadataWrapper = [wrappers objectForKey:kMetadataFileName];
    if (metadataWrapper) {
      NSData *plistData = [metadataWrapper regularFileContents];
      NSDictionary *metadata = [NSPropertyListSerialization propertyListFromData:plistData
                                                                mutabilityOption:NSPropertyListImmutable
                                                                          format:nil
                                                                errorDescription:nil];
      _filename = [[metadata objectForKey:kFilenameKey] copy];
      _contentType = [[metadata objectForKey:kContentTypeKey] copy];
    }
  }
  return self;
}

- (void)dealloc {
  [_filename release];
  [_contentType release];
  [super dealloc];
}

- (NSString *)filename {
  return _filename;
}

- (NSString *)contentType {
  return _contentType;
}

- (NSData *)regularFileContents {
  NSFileWrapper *dataWrapper = [[self fileWrappers] objectForKey:kDataFileName];
  return [dataWrapper regularFileContents];
}

@end
