#import "TDLDownload.h"

static NSString *const kContentTypeKey = @"contentType";
static NSString *const kRequestURLKey = @"requestURL";
static NSString *const kResponseURLKey = @"responseURL";
static NSString *const kServiceIdentKey = @"serviceIdent";
static NSString *const kStateKey = @"state";
static NSString *const kContentSizeKey = @"contentSize";
static NSString *const kErrorMsgKey = @"errorMessage";

@implementation TDLDownload

- (id)init {
  self = [super init];
  if (self) {
    _state = TDLDownloadStatePending;
    _contentSize = 0;
  }
  return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
  self = [self init];
  if (self) {
    _contentType = [[dict objectForKey:kContentTypeKey] copy];
    _requestURL = [[dict objectForKey:kRequestURLKey] copy];
    _responseURL = [[dict objectForKey:kResponseURLKey] copy];
    _serviceIdentifier = [[dict objectForKey:kServiceIdentKey] copy];
    _state = (TDLDownloadState)[[dict objectForKey:kStateKey] intValue];
    _contentSize = [[dict objectForKey:kContentSizeKey] longLongValue];
    _errorMessage = [[dict objectForKey:kErrorMsgKey] copy];
  }
  return self;
}

- (NSDictionary *)dictionaryRepresentation {
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  if (_contentType) [dict setObject:_contentType forKey:kContentTypeKey];
  if (_requestURL) [dict setObject:_requestURL forKey:kRequestURLKey];
  if (_responseURL) [dict setObject:_responseURL forKey:kResponseURLKey];
  if (_serviceIdentifier) [dict setObject:_serviceIdentifier forKey:kServiceIdentKey];
  [dict setObject:[NSNumber numberWithInt:(int)_state] forKey:kStateKey];
  [dict setObject:[NSNumber numberWithLongLong:_contentSize] forKey:kContentSizeKey];
  if (_errorMessage) [dict setObject:_errorMessage forKey:kErrorMsgKey];
  return dict;
}

- (void)dealloc {
  [_contentType release];
  [_requestURL release];
  [_responseURL release];
  [_serviceIdentifier release];
  [_errorMessage release];
  [super dealloc];
}

#pragma mark - Accessors

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

- (NSString *)serviceIdentifier { return _serviceIdentifier; }
- (void)setServiceIdentifier:(NSString *)ident {
  if (_serviceIdentifier != ident) {
    [_serviceIdentifier release];
    _serviceIdentifier = [ident copy];
  }
}

- (TDLDownloadState)state { return _state; }
- (void)setState:(TDLDownloadState)state { _state = state; }

- (long long)contentSize { return _contentSize; }
- (void)setContentSize:(long long)size { _contentSize = size; }

- (NSString *)errorMessage { return _errorMessage; }
- (void)setErrorMessage:(NSString *)msg {
  if (_errorMessage != msg) {
    [_errorMessage release];
    _errorMessage = [msg copy];
  }
}

@end
