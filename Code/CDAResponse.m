//
//  CDAResponse.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import "CDAResponse+Private.h"
#import "CDAUtilities.h"

@implementation CDAResponse

+(instancetype)responseWithHTTPURLResponse:(NSHTTPURLResponse*)response {
    return [[[self class] alloc] initWithHTTPURLResponse:response];
}

#pragma mark -

-(id)initWithHTTPURLResponse:(NSHTTPURLResponse*)response {
    NSURL* responseURL = response.URL ?: [NSURL URLWithString:@"http://example.com/"];
    NSParameterAssert(responseURL);

    self = [super initWithURL:responseURL
                   statusCode:response.statusCode
                  HTTPVersion:@"HTTP/1.1"
                 headerFields:response.allHeaderFields];
    return self;
}

@end
