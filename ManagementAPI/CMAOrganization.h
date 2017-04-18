//
//  CMAOrganization.h
//  Pods
//
//  Created by Boris Bügling on 29/07/14.
//
//

#import <ContentfulDeliveryAPI/CDANullabilityStubs.h>
#import <ContentfulManagementAPI/ContentfulManagementAPI.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  An organization on Contentful.
 */
@interface CMAOrganization : CDAResource

/**
 *  Whether or not the receiver is active. You cannot create spaces on inactive organizations.
 */
@property (nonatomic, readonly, getter = isActive) BOOL active;

/**
 *  The name of the receiver.
 */
@property (nonatomic, readonly) NSString* name;

@end

NS_ASSUME_NONNULL_END
