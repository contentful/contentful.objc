//
//  CMAWebhook.m
//  Pods
//
//  Created by Boris Bügling on 11/07/16.
//

#import "CDAResource+Management.h"
#import "CDAResource+Private.h"
#import "CMAWebhook.h"

#pragma mark -

@implementation CMAWebhook

+(NSString *)CDAType {
    return @"WebhookDefinition";
}

+(NSDictionary*)parametersForWebhookWithName:(NSString*)name
                                         url:(NSURL*)url
                                      topics:(NSArray*)topics
                                     headers:(NSDictionary*)headers
                           httpBasicUsername:(NSString*)httpBasicUsername
                           httpBasicPassword:(NSString*)httpBasicPassword {
    NSParameterAssert(url.absoluteString);
    NSMutableDictionary* parameters = [@{ @"name": name, @"url": (NSString * _Nonnull)url.absoluteString } mutableCopy];

    if (topics) {
        parameters[@"topics"] = topics;
    } else {
        parameters[@"topics"] = @[ @"*.*" ];
    }

    if (headers) {
        NSMutableArray* customHeaders = [@[] mutableCopy];
        [headers enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* value, BOOL* stop) {
            [customHeaders addObject:@{ @"key": key, @"value": value }];
        }];

        parameters[@"headers"] = customHeaders;
    }

    if (httpBasicUsername) {
        parameters[@"httpBasicUsername"] = httpBasicUsername;
    }

    if (httpBasicPassword) {
        parameters[@"httpBasicPassword"] = httpBasicPassword;
    }

    return [parameters copy];
}

#pragma mark -

-(CDARequest*)deleteWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure {
    return [self performDeleteToFragment:@"" withSuccess:success failure:failure];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ '%@': %@", self.class.CDAType, self.name, self.url];
}

-(id)initWithDictionary:(NSDictionary *)dictionary
                 client:(CDAClient *)client
  localizationAvailable:(BOOL)localizationAvailable {
    self = [super initWithDictionary:dictionary
                              client:client
               localizationAvailable:localizationAvailable];
    if (self) {
        self.httpBasicUsername = (NSString * _Nonnull)dictionary[@"httpBasicUsername"];
        self.name = (NSString * _Nonnull)dictionary[@"name"];
        self.topics = (NSArray * _Nonnull)dictionary[@"topics"];

        NSMutableDictionary* headers = [@{} mutableCopy];
        [dictionary[@"headers"] enumerateObjectsUsingBlock:^(NSDictionary* pair,
                                                             NSUInteger idx, BOOL * stop) {
            
//            headers[pair[@"key"]] = pair[@"value"];
        }];
        self.headers = [headers copy];

        NSString* urlString = dictionary[@"url"];
        if (urlString) {
            self.url = (NSURL * _Nonnull)[NSURL URLWithString:urlString];
        }
    }
    return self;
}

-(CDARequest *)updateWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure {
    NSDictionary* parameters = [self.class parametersForWebhookWithName:self.name
                                                                    url:self.url
                                                                 topics:self.topics
                                                                headers:self.headers
                                                      httpBasicUsername:self.httpBasicUsername
                                                      httpBasicPassword:self.httpBasicPassword];

    return [self performPutToFragment:@""
                       withParameters:parameters
                              success:success
                              failure:failure];
}

-(NSString *)URLPath {
    return [@"webhook_definitions" stringByAppendingPathComponent:self.identifier];
}

@end
