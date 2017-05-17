//
//  CDAResource+Management.m
//  Pods
//
//  Created by Boris Bügling on 30/07/14.
//
//

#import "CDAClient+Private.h"
#import "CDAResource+Management.h"
#import "CDAResource+Private.h"

@implementation CDAResource (Management)

-(NSDictionary*)linkDictionary {
    return @{ @"sys": @{ @"type": @"Link",
                         @"linkType": [self.class CDAType],
                         @"id": self.identifier } };
}

-(CDARequest*)performDeleteToFragment:(NSString*)fragment
                          withSuccess:(void (^)())success
                              failure:(CDARequestFailureBlock)failure {
    NSParameterAssert(self.client);
    return [self.client deleteURLPath:[self.URLPath stringByAppendingPathComponent:fragment]
                              headers:nil
                           parameters:nil
                              success:^(CDAResponse *response, CDAResource* resource) {
                                  [self updateWithResource:resource];

                                  if (success) {
                                      success();
                                  }
                              } failure:failure];
}

-(CDARequest*)performPutToFragment:(NSString*)fragment
                    withParameters:(NSDictionary*)parameters
                           success:(void (^)())success
                           failure:(CDARequestFailureBlock)failure {
    NSParameterAssert(self.client);
    return [self.client putURLPath:[self.URLPath stringByAppendingPathComponent:fragment]
                           headers:@{ @"X-Contentful-Version": [self.sys[@"version"] stringValue] }
                        parameters:parameters
                           success:^(CDAResponse *response, CDAResource* resource) {
                               [self updateWithResource:resource];

                               if (success) {
                                   success();
                               }
                           } failure:failure];
}

-(CDARequest *)performPutToFragment:(NSString *)fragment
                        withSuccess:(void (^)())success
                            failure:(CDARequestFailureBlock)failure {
    return [self performPutToFragment:fragment withParameters:nil success:success failure:failure];
}

-(NSString *)URLPath {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
