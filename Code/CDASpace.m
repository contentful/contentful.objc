//
//  CDASpace.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 06/03/14.
//
//

#import "CDAResource+Private.h"
#import "CDASpace.h"

@interface CDASpace ()

@property (nonatomic) NSArray* locales;
@property (nonatomic) NSString* name;

@end

#pragma mark -

@implementation CDASpace

+(NSString *)CDAType {
    return @"Space";
}

#pragma mark -

-(id)initWithDictionary:(NSDictionary *)dictionary client:(CDAClient*)client {
    self = [super initWithDictionary:dictionary client:client];
    if (self) {
        self.locales = dictionary[@"locales"];
        self.name = dictionary[@"name"];
    }
    return self;
}

@end
