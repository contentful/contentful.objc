//
//  CDAError.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 05/03/14.
//
//

#import <ContentfulDeliveryAPI/CDANullabilityStubs.h>
#import <ContentfulDeliveryAPI/CDAResource.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString* const CDAErrorDomain;

/**
 *  Details about errors which occured on the server.
 */
@interface CDAError : CDAResource

/**
 *  Detailed representation of the error.
 */
@property (nonatomic, readonly, nullable) NSDictionary* details;

/**
 *  Short message on the cause of the error.
 */
@property (nonatomic, readonly, nullable) NSString* message;

@end

NS_ASSUME_NONNULL_END
