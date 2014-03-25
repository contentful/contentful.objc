//
//  CDAArray.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import "CDAArray+Private.h"
#import "CDAResource+Private.h"

@interface CDAArray ()

@property (nonatomic) NSArray* items;
@property (nonatomic) NSUInteger limit;
@property (nonatomic) NSString* nextPageUrlString;
@property (nonatomic) NSString* nextSyncUrlString;
@property (nonatomic) NSUInteger skip;
@property (nonatomic) NSUInteger total;

@end

#pragma mark -

@implementation CDAArray

+(NSString *)CDAType {
    return @"Array";
}

#pragma mark -

-(NSString *)description {
    return self.items.description;
}

-(id)initWithDictionary:(NSDictionary*)dictionary client:(CDAClient*)client {
    self = [super initWithDictionary:dictionary client:client];
    if (self) {
        self.limit = [dictionary[@"limit"] unsignedIntegerValue];
        self.skip = [dictionary[@"skip"] unsignedIntegerValue];
        self.total = [dictionary[@"total"] unsignedIntegerValue];
        
        self.nextPageUrlString = dictionary[@"nextPageUrl"];
        self.nextSyncUrlString = dictionary[@"nextSyncUrl"];
        
        NSMutableArray* items = [@[] mutableCopy];
        for (NSDictionary* item in dictionary[@"items"]) {
            CDAResource* resource = [CDAResource resourceObjectForDictionary:item client:self.client];
            [items addObject:resource];
        }
        self.items = [items copy];
    }
    return self;
}

-(NSURL *)nextPageUrl {
    return self.nextPageUrlString ? [NSURL URLWithString:self.nextPageUrlString] : nil;
}

-(NSURL *)nextSyncUrl {
    return self.nextSyncUrlString ? [NSURL URLWithString:self.nextSyncUrlString] : nil;
}

-(void)resolveLinksWithIncludedAssets:(NSDictionary*)assets entries:(NSDictionary*)entries {
    for (CDAResource* item in self.items) {
        [item resolveLinksWithIncludedAssets:assets entries:entries];
    }
}

@end
