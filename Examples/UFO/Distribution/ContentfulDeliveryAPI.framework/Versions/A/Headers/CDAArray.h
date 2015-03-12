//
//  CDAArray.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAResource.h>

/**
 A list of resources which was retrieved from the server.
 */
@interface CDAArray : CDAResource

/** @name Accessing Local Data */

/** A list of items available locally. */
@property (nonatomic, readonly) NSArray* items;

/** @name Information about Remote Data */

/** The maximum number of resources available in items. */
@property (nonatomic, readonly) NSUInteger limit;
/** The offset of items in terms of all data available on the server. */
@property (nonatomic, readonly) NSUInteger skip;
/** The total number of resources which are available on the server. */
@property (nonatomic, readonly) NSUInteger total;

/** @name Errors in Remote Data */

/** 
 *  An array of non-fatal errors encountered while fetching the receiver.
 *
 *  For example, if there is a link to an Entry which no longer exists, there will be a `notResolvable`
 *  error in the `errors` array.
 */
@property (nonatomic, readonly) NSArray* errors;

@end
