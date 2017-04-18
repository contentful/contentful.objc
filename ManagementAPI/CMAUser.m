//
//  CMAUser.m
//  Pods
//
//  Created by Boris Bügling on 15/09/14.
//
//

#import "CDAResource+Private.h"
#import "CMAUser.h"

@interface CMAUser ()

@property (nonatomic) NSURL* avatarURL;
@property (nonatomic) NSString* firstName;
@property (nonatomic) NSString* lastName;

@end

#pragma mark -

@implementation CMAUser

+(NSString *)CDAType {
    return @"User";
}

#pragma mark -

-(id)initWithDictionary:(NSDictionary *)dictionary
                 client:(CDAClient *)client
  localizationAvailable:(BOOL)localizationAvailable {
    self = [super initWithDictionary:dictionary
                              client:client
               localizationAvailable:localizationAvailable];
    if (self) {
        self.firstName = dictionary[@"firstName"];
        self.lastName = dictionary[@"lastName"];

        NSString* urlString = dictionary[@"avatarUrl"];
        if (urlString) {
            self.avatarURL = [NSURL URLWithString:urlString];
        }
    }
    return self;
}

@end
