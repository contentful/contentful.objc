//
//  CMAArchiving.h
//  Pods
//
//  Created by Boris Bügling on 28/07/14.
//
//

#import <ContentfulDeliveryAPI/CDANullabilityStubs.h>
#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol for resources which support archiving.
 */
@protocol CMAArchiving

/**
 *  Determine whether or not the receiver is currently archived.
 */
@property (readonly, getter = isArchived) BOOL archived;

/**
 *  Archive the receiver. 
 *
 *  This operation only works on unpublished resources and will exclude them from default queries.
 *
 *  @param success Called if archiving succeeds.
 *  @param failure Called if archiving fails.
 *
 *  @return The request used for archiving.
 */
-(CDARequest *)archiveWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure;

/**
 *  Unarchive the receiver.
 *
 *  This operation only works on archived resources.
 *
 *  @param success Called if unarchiving succeeds.
 *  @param failure Called if unarchiving fails.
 *
 *  @return The request used for unarchiving.
 */
-(CDARequest *)unarchiveWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure;

@end

NS_ASSUME_NONNULL_END
