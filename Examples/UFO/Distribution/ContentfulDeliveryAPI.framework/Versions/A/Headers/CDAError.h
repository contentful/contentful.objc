//
//  CDAError.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 05/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAResource.h>

extern NSString* const CDAErrorDomain;

/**
 *  Details about errors which occured on the server.
 */
@interface CDAError : CDAResource

/**
 *  Detailed representation of the error.
 */
@property (nonatomic, readonly) NSDictionary* details;

/**
 *  Short message on the cause of the error.
 */
@property (nonatomic, readonly) NSString* message;

@end
