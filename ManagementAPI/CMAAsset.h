//
//  CMAAsset.h
//  Pods
//
//  Created by Boris Bügling on 28/07/14.
//
//

#import <ContentfulDeliveryAPI/CDANullabilityStubs.h>
#import <ContentfulManagementAPI/ContentfulManagementAPI.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Management extensions for assets.
 */
@interface CMAAsset : CDAAsset <CMAArchiving, CMAPublishing, CMAResource>

/**
 *  The description of the receiver.
 */
@property (nonatomic) NSString* description;

/**
 *  The title of the receiver.
 */
@property (nonatomic) NSString* title;

/**
 *  Initiate processing of the uploaded file of the receiver.
 *
 *  Processing is required to publish an asset. This call will only initiate the processing, it is
 *  not finished when it is completed, because processing happens completely asynchronous.
 *
 *  @param success Called if processing is successfully initiated.
 *  @param failure Called if processing could not be initiated.
 *
 *  @return The request for initiating processing.
 */
-(CDARequest*)processWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure;

/**
 *  Update the receiver with new values.
 *
 *  Before an update will be active on the delivery API, you have to republish it, until then, the
 *  last published version will continue to be active.
 *
 *  @param localizedUploads File URLs to upload for all relevant locales.
 *  @param success          Called if update succeeds.
 *  @param failure          Called if update fails.
 *
 *  @return The request used for updating.
 */
-(CDARequest *)updateWithLocalizedUploads:(NSDictionary*)localizedUploads
                                  success:(void (^)())success
                                  failure:(CDARequestFailureBlock)failure;

@end

NS_ASSUME_NONNULL_END
