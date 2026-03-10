#import <Foundation/Foundation.h>

@class TDLDownloadList;

/**
 * Manages the available download services.
 */
@interface TDLServiceManager : NSObject {
 @private
  NSArray *_services;
}

/**
 * Initializes the manager with a download list manager.
 *
 * @param downloadList The manager to pass to all services.
 */
- (id)initWithDownloadList:(TDLDownloadList *)downloadList;

/** Returns the list of registered TDLService objects. */
- (NSArray *)availableServices;

@end
