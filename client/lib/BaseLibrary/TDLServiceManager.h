#import <Foundation/Foundation.h>

/**
 * Manages the available download services.
 */
@interface TDLServiceManager : NSObject {
 @private
  NSArray *_services;
}

/** Returns the shared manager instance. */
+ (TDLServiceManager *)sharedManager;

/** Returns the list of registered TDLService objects. */
- (NSArray *)availableServices;

@end
