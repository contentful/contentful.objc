//
//  CMAEditorInterface.h
//  Pods
//
//  Created by Boris Bügling on 11/07/16.
//
//

#import <ContentfulDeliveryAPI/CDANullabilityStubs.h>
#import <ContentfulManagementAPI/ContentfulManagementAPI.h>

NS_ASSUME_NONNULL_BEGIN

/** Editor interface for a content type. */
@interface CMAEditorInterface : CDAResource

/** Array of controls */
@property (nonatomic, copy) NSArray* controls;

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
