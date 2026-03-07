#import <Foundation/Foundation.h>

/**
 * An abstract base class for download services.
 */
@interface TDLService : NSObject

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
 * Returns a list of active or recently failed download tasks.
 *
 * @return An NSArray of task descriptions or objects.
 */
- (NSArray *)activeTasks;

/**
 * Returns a dictionary of sample URLs for testing.
 * Keys are display names, values are URL strings.
 */
+ (NSDictionary *)sampleURLs;

@end
