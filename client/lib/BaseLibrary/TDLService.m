#import "TDLService.h"

@implementation TDLService

- (NSString *)serviceName {
  return @"Base Service";
}

- (NSString *)serviceIdentifier {
  return @"com.kumasan.thedl.service.base";
}

- (void)fetchURL:(NSURL *)url {
  // To be implemented by subclasses.
}

- (NSArray *)activeTasks {
  return [NSArray array];
}

- (void)dealloc {
  [super dealloc];
}

@end
