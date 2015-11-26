//
//  CDAResponse.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

/**
 A `CDAResponse` encapsulates meta-information about a reponse received from the server, such as the 
 HTTP status code or headers.
 */
@interface CDAResponse : NSHTTPURLResponse

@end
