//
//  CMAUser.h
//  Pods
//
//  Created by Boris Bügling on 15/09/14.
//
//

#import <ContentfulDeliveryAPI/CDANullabilityStubs.h>
#import <ContentfulManagementAPI/ContentfulManagementAPI.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Represents metadata of a Contentful user account.
 */
@interface CMAUser : CDAResource

/**
 *  URL of the user's avatar image.
 */
@property (nonatomic, readonly) NSURL* avatarURL;

/**
 *  First name of the user.
 */
@property (nonatomic, readonly) NSString* firstName;

/**
 *  Last name of the user.
 */
@property (nonatomic, readonly) NSString* lastName;

@end

NS_ASSUME_NONNULL_END
