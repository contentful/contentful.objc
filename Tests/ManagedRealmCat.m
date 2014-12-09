//
//  ManagedRealmCat.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 08/12/14.
//
//

#import "ManagedRealmCat.h"

@implementation ManagedRealmCat

@synthesize identifier;

#pragma mark -

-(instancetype)init {
    self = [super init];
    if (self) {
        self.color = @"";
        self.identifier = @"";
        self.name = @"";
    }
    return self;
}

@end
