//
//  CDAConfiguration.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import "CDAConfiguration.h"

@implementation CDAConfiguration

+(instancetype)defaultConfiguration {
    CDAConfiguration* configuration = [CDAConfiguration new];
    configuration.secure = YES;
    configuration.server = @"cdn.contentful.com";
    return configuration;
}

@end
