//
//  CMAApiKey.m
//  Pods
//
//  Created by Boris Bügling on 16/01/15.
//
//

#import "CDAResource+Private.h"
#import "CMAApiKey.h"

@interface CMAApiKey ()

@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* token;
@property (nonatomic, copy) NSString* tokenDescription;

@end

#pragma mark -

@implementation CMAApiKey

+(NSString *)CDAType {
    return @"ApiKey";
}

#pragma mark -

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ '%@': %@", self.class.CDAType, self.name, self.token];
}

-(id)initWithDictionary:(NSDictionary *)dictionary
                 client:(CDAClient *)client
  localizationAvailable:(BOOL)localizationAvailable {
    self = [super initWithDictionary:dictionary
                              client:client
               localizationAvailable:localizationAvailable];
    if (self) {
        self.name = dictionary[@"name"];
        self.token = dictionary[@"accessToken"];
        self.tokenDescription = dictionary[@"description"];
    }
    return self;
}

@end
