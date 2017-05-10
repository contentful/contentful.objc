//
//  CMAValidation.h
//  Pods
//
//  Created by Boris Bügling on 17/11/14.
//
//

#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation>
#endif

#import "CDANullabilityStubs.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Objects of this class represent a single validation rule for field values.
 */
@interface CMAValidation : NSObject

/**
 *  Validate the number of objects in an array.
 *
 *  @param min Minimum required number of objects.
 *  @param max Maximum allowed number of objects.
 *
 *  @return A validation object conforming to the given rule.
 */
+(CMAValidation*)validationOfArraySizeWithMinimumValue:(NSNumber*)min
                                          maximumValue:(NSNumber* __nullable)max;

/**
 *  Validate that links only target entries of one of the given content types.
 *
 *  @param contentTypeIds A list of content type identifiers.
 *
 *  @return A validation object conforming to the given rule.
 */
+(CMAValidation*)validationOfLinksAgainstContentTypeIdentifiers:(NSArray*)contentTypeIds;

/**
 *  Validate that links only target assets of the given MIME type group, e.g. "image".
 *
 *  @param group The name of a MIME type group (e.g. "image").
 *
 *  @return A validation object conforming to the given rule.
 */
+(CMAValidation*)validationOfLinksAgainstMimeTypeGroup:(NSString*)group;

/**
 *  Validate that a field value of type string matches the given JavaScript regular expression and flags.
 *  See [JS Reference](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp)
 *  for the parameters.
 *
 *  @param pattern The regular expression pattern.
 *  @param flags   The regular expression's flags.
 *
 *  @return A validation object conforming to the given rule.
 */
+(CMAValidation*)validationOfRegularExpression:(NSString*)pattern flags:(NSString*)flags;

/**
 *  Validates that the field value is one of the values in the given array.
 *
 *  @param valueArray An array of values.
 *
 *  @return A validation object conforming to the given rule.
 */
+(CMAValidation*)validationOfValueInArray:(NSArray*)valueArray;

/**
 *  Validates that a field value is within a certain range.
 *
 *  @param min Minimum value of the range.
 *  @param max Maximum value of the range.
 *
 *  @return A validation object conforming to the given rule.
 */
+(CMAValidation*)validationOfValueRangeWithMinimumValue:(NSNumber*)min maximumValue:(NSNumber*)max;

@end

NS_ASSUME_NONNULL_END
