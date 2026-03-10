#import <Foundation/Foundation.h>

/**
 * A protocol that defines the interface for download services.
 */
@protocol TDLService <NSObject>

/** Returns the display name of the service. */
- (NSString *)serviceName;

/** Returns the unique identifier of the service. */
- (NSString *)serviceIdentifier;

/**
 * Initiates a fetch for the given URL.
 *
 * @param url The URL to download.
 */
- (void)fetchURL:(NSURL *)url;

/**
 * Returns a list of active download tasks.
 */
- (NSArray *)activeTasks;

@end
