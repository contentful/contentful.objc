//
//  CMAPublishing.h
//  Pods
//
//  Created by Boris Bügling on 28/07/14.
//
//

@import Foundation;

#import <ContentfulDeliveryAPI/CDANullabilityStubs.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol for resources which support publishing.
 */
@protocol CMAPublishing

/**
 *  Determine whether or not the receiver is currently published.
 */
@property (readonly, getter = isPublished) BOOL published;

/**
 *  Publish the receiver. A published resource will be available via the delivery API.
 *
 *  Before publishing certain resources, Contentful will perform validations, so publishing can fail
 *  based on those.
 *
 *  @param success Called if publishing succeeds.
 *  @param failure Called if publishing fails.
 *
 *  @return The request used for publishing.
 */
-(CDARequest *)publishWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure;

/**
 *  Unpublish the receiver. An unpublished resource will no longer be available via the delivery API.
 *
 *  @param success Called if unpublishing succeeds.
 *  @param failure Called if unpublishing fails.
 *
 *  @return The request used for unpublishing.
 */
-(CDARequest *)unpublishWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure;

@end

NS_ASSUME_NONNULL_END
