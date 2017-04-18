//
//  CMALocale.m
//  Pods
//
//  Created by Boris Bügling on 08/08/14.
//
//

#import "CDAResource+Management.h"
#import "CDAResource+Private.h"
#import "CMALocale.h"

@interface CMALocale ()

@property (nonatomic) NSString* code;
@property (nonatomic, getter = isDefault) BOOL defaultLocale;

@end

#pragma mark -

@implementation CMALocale

+(NSString *)CDAType {
    return @"Locale";
}

#pragma mark -

-(CDARequest *)deleteWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure {
    return [self performDeleteToFragment:@"" withSuccess:success failure:failure];
}

-(NSDictionary*)dictionaryRepresentation {
    return @{ @"name": self.name, @"code": self.code };
}

-(id)initWithDictionary:(NSDictionary *)dictionary
                 client:(CDAClient *)client
  localizationAvailable:(BOOL)localizationAvailable {
    self = [super initWithDictionary:dictionary
                              client:client
               localizationAvailable:localizationAvailable];
    if (self) {
        self.code = dictionary[@"code"];
        self.defaultLocale = [dictionary[@"default"] boolValue];
        self.name = (NSString* _Nonnull)dictionary[@"name"];
        self.optional = [dictionary[@"optional"] boolValue];
    }
    return self;
}

-(CDARequest *)updateWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure {
    return [self performPutToFragment:@""
                       withParameters:@{ @"name": self.name,
                                         @"optional": @(self.isOptional) }
                              success:success
                              failure:failure];
}

-(NSString *)URLPath {
    return [@"locales" stringByAppendingPathComponent:self.identifier];
}

@end
