#import <Foundation/Foundation.h>
#import "XPObject.h"

/**
 * A base class for object-level logic in TheDL.
 */
@interface TDLObject : NSObject {
 @private
  int _tag;
}

/** Returns the tag associated with this object. */
- (int)tag;

/**
 * Sets the tag for this object.
 *
 * @param tag The tag to set.
 */
- (void)setTag:(int)tag;

/**
 * Returns platform information using the CrossPlatform library.
 *
 * @return A string with platform details.
 */
- (NSString *)platformInfo;

@end
