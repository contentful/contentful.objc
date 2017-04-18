//
//  CMAAccessToken.m
//  Pods
//
//  Created by Boris Bügling on 29/07/14.
//
//

#import "CMAAccessToken.h"
#import "CDAResource+Private.h"

@implementation CMAAccessToken

@synthesize organizations;

#pragma mark -

+(NSString *)CDAType {
    return @"AccessToken";
}

@end
