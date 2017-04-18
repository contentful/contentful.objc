//
//  CMARole.m
//  Pods
//
//  Created by Boris Bügling on 05/07/16.
//

#import "CDAResource+Private.h"
#import "CDAResource+Management.h"
#import "CMARole.h"

@implementation CMARole

+(NSString *)CDAType {
    return @"Role";
}

#pragma mark -

-(CDARequest*)deleteWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure {
    return [self performDeleteToFragment:@"" withSuccess:success failure:failure];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ '%@'", self.class.CDAType, self.name];
}

-(id)initWithDictionary:(NSDictionary *)dictionary
                 client:(CDAClient *)client
  localizationAvailable:(BOOL)localizationAvailable {
    self = [super initWithDictionary:dictionary
                              client:client
               localizationAvailable:localizationAvailable];
    if (self) {
        self.name = (NSString * _Nonnull)dictionary[@"name"];
        self.permissions = (NSDictionary * _Nonnull)dictionary[@"permissions"];
        self.policies = (NSArray * _Nonnull)dictionary[@"policies"];
        self.roleDescription = (NSString * _Nonnull)dictionary[@"description"];
    }
    return self;
}

-(CDARequest *)updateWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure {
    return [self performPutToFragment:@""
                       withParameters:@{ @"name": self.name,
                                         @"permissions": self.permissions,
                                         @"policies": self.policies,
                                         @"description": self.roleDescription
                                       }
                              success:success
                              failure:failure];
}

-(NSString *)URLPath {
    return [@"roles" stringByAppendingPathComponent:self.identifier];
}

@end
