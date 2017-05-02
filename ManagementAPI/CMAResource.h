//
//  CMAResource.h
//  Pods
//
//  Created by Boris Bügling on 28/07/14.
//
//

@import Foundation;

#import "CDANullabilityStubs.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol for managing resources.
 */
@protocol CMAResource

/**
 *  Delete the receiver. Published resources cannot be deleted.
 *
 *  Once deleted, a resource cannot be restored, use archiving or unpublishing if you temporarily want 
 *  to disable a resource temporarily.
 *
 *  @param success Called if deletion succeeds.
 *  @param failure Called if deletion fails.
 *
 *  @return The request used for deletion.
 */
-(CDARequest*)deleteWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure;

/**
 *  Update the receiver with new values.
 *
 *  Before an update will be active on the delivery API, you have to republish it, until then, the 
 *  last published version will continue to be active.
 *
 *  @param success Called if the update succeeds.
 *  @param failure Called if the update fails.
 *
 *  @return The request used for updating.
 */
-(CDARequest*)updateWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure;

@end

NS_ASSUME_NONNULL_END
