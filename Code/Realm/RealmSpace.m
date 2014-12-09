//
//  RealmSpace.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 08/12/14.
//
//

#import "RealmSpace.h"

@implementation RealmSpace

@synthesize lastSyncTimestamp;
@synthesize syncToken;

#pragma mark -

-(instancetype)init {
    self = [super init];
    if (self) {
        self.lastSyncTimestamp = [NSDate dateWithTimeIntervalSince1970:0];
        self.syncToken = @"";
    }
    return self;
}

@end
