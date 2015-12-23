//
//  CDARequest.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 10/03/14.
//
//

#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

#import <ContentfulDeliveryAPI/CDANullabilityStubs.h>

/**
 A request encapsulates all necessary information for retrieving specific resources.
 */
@interface CDARequest : NSOperation

/** @name Accessing URL Connection Information */

/** Error which occured during the lifetime of the request, if any. */
@property (readonly, nonatomic) NSError* __nullable error;
/** The actual request being sent to the server. */
@property (readonly, nonatomic) NSURLRequest* __nullable request;
/** The underlying response received from the server. */
@property (readonly, nonatomic) NSHTTPURLResponse* __nullable response;

/** @name Accessing Response Data */

/** Encoding used for the response. */
@property (readonly, nonatomic) NSStringEncoding responseStringEncoding;

@end
