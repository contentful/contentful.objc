//
//  RealmAsset.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 08/12/14.
//
//

#import "RealmAsset.h"

@interface RealmAsset ()

@property (nonatomic, assign) long realm_width;
@property (nonatomic, assign) long realm_height;

@end

#pragma mark -

@implementation RealmAsset

@synthesize identifier;
@synthesize internetMediaType;
@synthesize url;

#pragma mark -

+(NSArray*)ignoredProperties {
    return @[ @"width", @"height" ];
}

#pragma mark -

-(NSNumber *)height {
    return @(self.realm_height);
}

-(instancetype)init {
    self = [super init];
    if (self) {
        self.identifier = @"";
        self.internetMediaType = @"";
        self.url = @"";
    }
    return self;
}

-(void)setHeight:(NSNumber *)height {
    self.realm_height = height.longValue;
}

-(void)setWidth:(NSNumber *)width {
    self.realm_width = width.longValue;
}

-(NSNumber *)width {
    return @(self.realm_width);
}

@end
