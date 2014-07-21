//
//  CDARequestSerializer.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 21/07/14.
//
//

#import "CDARequestSerializer.h"

@implementation CDARequestSerializer

-(id)init {
    self = [super init];
    if (self) {
        NSString* userAgent = self.HTTPRequestHeaders[@"User-Agent"];
        userAgent = [userAgent stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
        NSRange bracketRange = [userAgent rangeOfString:@"("];
        [self setValue:[userAgent stringByReplacingCharactersInRange:NSMakeRange(0, bracketRange.location - 1) withString:@"contentful.objc/1.3.0"] forHTTPHeaderField:@"User-Agent"];
    }
    return self;
}

@end
