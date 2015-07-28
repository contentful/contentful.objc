//
//  CDASpace.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 06/03/14.
//
//

#import "CDAResource+Private.h"
#import "CDASpace+Private.h"

@interface CDASpace ()

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
        self.defaultLocale = @"en-US";
        self.locales = dictionary[@"locales"];
        self.name = dictionary[@"name"];
        
        for (NSDictionary* locale in self.locales) {
            if ([locale[@"default"] boolValue] && locale[@"code"]) {
                NSString* code = locale[@"code"];
                self.defaultLocale = code;
            }
        }
    }
    return self;
}

-(NSArray *)localeCodes {
    return [self.locales valueForKey:@"code"] ?: @[ self.defaultLocale ];
}

@end
