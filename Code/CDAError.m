//
//  CDAError.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 05/03/14.
//
//

#import "CDAError+Private.h"
#import "CDAResource+Private.h"

NSString* const CDAErrorDomain = @"CDAErrorDomain";

@interface CDAError ()

@property (nonatomic) NSDictionary* details;
@property (nonatomic) NSString* message;

@end

#pragma mark -

@implementation CDAError

+(NSError*)buildErrorWithCode:(NSInteger)code userInfo:(NSDictionary*)userInfo {
    return [NSError errorWithDomain:CDAErrorDomain
                               code:code
                           userInfo:userInfo];
}

+(NSString *)CDAType {
    return @"Error";
}

#pragma mark -

-(NSString *)description {
    return [[self errorRepresentationWithCode:0] description];
}

-(NSError *)errorRepresentationWithCode:(NSInteger)code {
    return [[self class] buildErrorWithCode:code
                                   userInfo:@{ @"details": self.details ?: @{},
                                               @"identifier": self.identifier,
                                               NSLocalizedDescriptionKey: self.message ?: @"" }];
}

-(id)initWithDictionary:(NSDictionary *)dictionary client:(CDAClient*)client {
    self = [super initWithDictionary:dictionary client:client];
    if (self) {
        self.details = dictionary[@"details"];
        self.message = dictionary[@"message"];
    }
    return self;
}

@end
