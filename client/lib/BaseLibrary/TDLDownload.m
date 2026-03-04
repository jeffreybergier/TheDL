#import "TDLDownload.h"

static NSString *const kDisplayNameKey = @"displayName";
static NSString *const kFilePathKey = @"filePath";
static NSString *const kContentTypeKey = @"contentType";
static NSString *const kRequestURLKey = @"requestURL";
static NSString *const kResponseURLKey = @"responseURL";
static NSString *const kActualSizeKey = @"actualSize";
static NSString *const kContentSizeKey = @"contentSize";

@implementation TDLDownload

- (id)init {
  self = [super init];
  if (self) {
    _actualSize = 0;
    _contentSize = 0;
  }
  return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
  self = [self init];
  if (self) {
    _displayName = [[dict objectForKey:kDisplayNameKey] copy];
    _filePath = [[dict objectForKey:kFilePathKey] copy];
    _contentType = [[dict objectForKey:kContentTypeKey] copy];
    _requestURL = [[dict objectForKey:kRequestURLKey] copy];
    _responseURL = [[dict objectForKey:kResponseURLKey] copy];
    _actualSize = [[dict objectForKey:kActualSizeKey] longLongValue];
    _contentSize = [[dict objectForKey:kContentSizeKey] longLongValue];
  }
  return self;
}

- (id)initWithURL:(NSURL *)url options:(unsigned int)options error:(NSError **)outError {
  NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[url path]];
  if (!dict) {
    [self release];
    return nil;
  }
  return [self initWithDictionary:dict];
}

- (NSDictionary *)dictionaryRepresentation {
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  if (_displayName) [dict setObject:_displayName forKey:kDisplayNameKey];
  if (_filePath) [dict setObject:_filePath forKey:kFilePathKey];
  if (_contentType) [dict setObject:_contentType forKey:kContentTypeKey];
  if (_requestURL) [dict setObject:_requestURL forKey:kRequestURLKey];
  if (_responseURL) [dict setObject:_responseURL forKey:kResponseURLKey];
  [dict setObject:[NSNumber numberWithLongLong:_actualSize] forKey:kActualSizeKey];
  [dict setObject:[NSNumber numberWithLongLong:_contentSize] forKey:kContentSizeKey];
  return dict;
}

- (void)dealloc {
  [_displayName release];
  [_filePath release];
  [_contentType release];
  [_requestURL release];
  [_responseURL release];
  [super dealloc];
}

#pragma mark - Accessors

- (NSString *)displayName { return _displayName; }
- (void)setDisplayName:(NSString *)name {
  if (_displayName != name) {
    [_displayName release];
    _displayName = [name copy];
  }
}

- (NSString *)filePath { return _filePath; }
- (void)setFilePath:(NSString *)path {
  if (_filePath != path) {
    [_filePath release];
    _filePath = [path copy];
  }
}

- (NSString *)contentType { return _contentType; }
- (void)setContentType:(NSString *)type {
  if (_contentType != type) {
    [_contentType release];
    _contentType = [type copy];
  }
}

- (NSString *)requestURL { return _requestURL; }
- (void)setRequestURL:(NSString *)url {
  if (_requestURL != url) {
    [_requestURL release];
    _requestURL = [url copy];
  }
}

- (NSString *)responseURL { return _responseURL; }
- (void)setResponseURL:(NSString *)url {
  if (_responseURL != url) {
    [_responseURL release];
    _responseURL = [url copy];
  }
}

- (long long)actualSize { return _actualSize; }
- (void)setActualSize:(long long)size { _actualSize = size; }

- (long long)contentSize { return _contentSize; }
- (void)setContentSize:(long long)size { _contentSize = size; }

@end
