//
//  CDAResponse.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import "CDAResponse+Private.h"

@implementation CDAResponse

+(instancetype)responseWithHTTPURLResponse:(NSHTTPURLResponse*)response {
    return [[[self class] alloc] initWithHTTPURLResponse:response];
}

#pragma mark -

-(id)initWithHTTPURLResponse:(NSHTTPURLResponse*)response {
    self = [super initWithURL:response.URL
                   statusCode:response.statusCode
                  HTTPVersion:@"HTTP/1.1"
                 headerFields:response.allHeaderFields];
    return self;
}

@end
