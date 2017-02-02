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

-(id)initWithDictionary:(NSDictionary *)dictionary
                 client:(CDAClient*)client
  localizationAvailable:(BOOL)localizationAvailable {
    self = [super initWithDictionary:dictionary client:client localizationAvailable:localizationAvailable];
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

// We only encode properties that have write permissions
#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.name           = [aDecoder decodeObjectForKey:@"name"];
        self.defaultLocale  = [aDecoder decodeObjectForKey:@"defaultLocale"];
        self.locales        = [aDecoder decodeObjectForKey:@"locales"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.defaultLocale forKey:@"defaultLocale"];
    [aCoder encodeObject:self.locales forKey:@"locales"];
}

@end
