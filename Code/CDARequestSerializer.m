//
//  CDARequestSerializer.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 21/07/14.
//
//

#import "CDARequestSerializer.h"

@implementation CDARequestSerializer

-(id)initWithAccessToken:(NSString*)accessToken {
    NSParameterAssert(accessToken);

    self = [super init];
    if (self) {
        [self setValue:[@"Bearer " stringByAppendingString:accessToken] forHTTPHeaderField:@"Authorization"];

        self.userAgent = @"contentful.objc/1.4.4";
    }
    return self;
}

-(void)setUserAgent:(NSString *)userAgent {
    if (_userAgent == userAgent) {
        return;
    }

    _userAgent = userAgent;

    NSString* userAgentHeader = self.HTTPRequestHeaders[@"User-Agent"];
    userAgentHeader = [userAgentHeader stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    NSRange bracketRange = [userAgentHeader rangeOfString:@"("];
    [self setValue:[userAgentHeader stringByReplacingCharactersInRange:NSMakeRange(0, bracketRange.location - 1) withString:userAgent] forHTTPHeaderField:@"User-Agent"];
}

@end
