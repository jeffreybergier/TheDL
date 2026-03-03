#import <Foundation/Foundation.h>

/**
 * A shared base class for cross-platform objects.
 */
@interface XPObject : NSObject

/**
 * Returns a string representing the platform the object is running on.
 *
 * @return A platform description string.
 */
- (NSString *)platformName;

@end
