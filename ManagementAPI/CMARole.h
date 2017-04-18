//
//  CMARole.h
//  Pods
//
//  Created by Boris Bügling on 05/07/16.
//

#import <ContentfulDeliveryAPI/CDANullabilityStubs.h>
#import <ContentfulManagementAPI/ContentfulManagementAPI.h>

NS_ASSUME_NONNULL_BEGIN

/** Role of a Space. */
@interface CMARole : CDAResource <CMAResource>

/** Name of the role */
@property (nonatomic, copy) NSString* name;

/** The permissions of the role */
@property (nonatomic, copy) NSDictionary* permissions;

/** The policies of the role */
@property (nonatomic, copy) NSArray* policies;

/** Description of the role */
@property (nonatomic, copy) NSString* roleDescription;

@end

NS_ASSUME_NONNULL_END
