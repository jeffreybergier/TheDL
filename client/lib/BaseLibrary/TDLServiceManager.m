#import "TDLServiceManager.h"
#import "TDLURLConnectionService.h"
#import "TDLCURLRequestService.h"

@implementation TDLServiceManager

- (id)initWithDownloadList:(TDLDownloadList *)downloadList {
  self = [super init];
  if (self) {
    NSMutableArray *services = [[NSMutableArray alloc] init];
    
    TDLURLConnectionService *urlService = [[TDLURLConnectionService alloc] initWithDownloadList:downloadList];
    [services addObject:urlService];
    [urlService release];
    
#if THEDL_CURL_ENABLED
    TDLCURLRequestService *curlService = [[TDLCURLRequestService alloc] initWithDownloadList:downloadList];
    [services addObject:curlService];
    [curlService release];
#endif
    
    _services = [services copy];
    [services release];
  }
  return self;
}

- (void)dealloc {
  [_services release];
  [super dealloc];
}

- (NSArray *)availableServices {
  return _services;
}

@end
