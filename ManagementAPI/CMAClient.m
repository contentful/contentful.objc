//
//  CMAClient.m
//  ManagementSDK
//
//  Created by Boris Bügling on 14/07/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>

#import "CDAArray+Private.h"
#import "CDAClient+Private.h"
#import "CDAResource+Private.h"
#import "CDASpace+Private.h"
#import "CMAAccessToken.h"
#import "CMAClient.h"

@interface CMAClient ()

@property (nonatomic) CDAClient* client;

@end

#pragma mark -

@implementation CMAClient

-(CDARequest *)createSpaceWithName:(NSString *)name
                    inOrganization:(CMAOrganization *)organization
                           success:(CMASpaceFetchedBlock)success
                           failure:(CDARequestFailureBlock)failure {
    NSDictionary* headers = nil;

    if (organization) {
        headers = @{ @"X-Contentful-Organization": organization.identifier };
    }

    NSParameterAssert(self.client);
    return [self.client postURLPath:@"spaces"
                            headers:headers
                         parameters:@{ @"name": name }
                            success:success
                            failure:failure];
}

-(CDARequest *)createSpaceWithName:(NSString *)name
                           success:(CMASpaceFetchedBlock)success
                           failure:(CDARequestFailureBlock)failure {
    return [self createSpaceWithName:name inOrganization:nil success:success failure:failure];
}

-(CDARequest *)fetchAllSpacesWithSuccess:(CDAArrayFetchedBlock)success
                                 failure:(CDARequestFailureBlock)failure {
    return [self.client fetchArrayAtURLPath:@"spaces"
                                 parameters:@{ @"limit": @100 }
                                    success:success
                                    failure:failure];
}

-(CDARequest *)fetchOrganizationsWithSuccess:(CDAArrayFetchedBlock)success
                                     failure:(CDARequestFailureBlock)failure {
    return [self.client fetchArrayAtURLPath:@"token"
                                 parameters:nil
                                    success:^(CDAResponse *response, CDAArray *array) {
                                        NSMutableArray* orgs = [@[] mutableCopy];

                                        for (CMAAccessToken* token in array.items) {
                                            [orgs addObjectsFromArray:token.organizations];
                                        }

                                        if (success) {
                                            success(response,
                                                    [[CDAArray alloc] initWithItems:orgs
                                                                             client:self.client]);
                                        }
                                    } failure:failure];
}

-(CDARequest *)fetchSpaceWithIdentifier:(NSString *)identifier
                                success:(CMASpaceFetchedBlock)success
                                failure:(CDARequestFailureBlock)failure {
    NSString* spaceURLPath = [@"spaces" stringByAppendingPathComponent:identifier];
    NSString* localesURLPath = [spaceURLPath stringByAppendingPathComponent:@"locales"];

    return [self.client fetchURLPath:spaceURLPath
                          parameters:@{}
                             success:^(CDAResponse *response, CMASpace* space) {
                                 [self.client fetchArrayAtURLPath:localesURLPath
                                                       parameters:nil
                                                          success:^(CDAResponse *secondResponse,
                                                                    CDAArray *array) {
                                                              for (CMALocale* locale in array.items) {
                                                                  if (locale.isDefault) {
                                                                      space.defaultLocale = locale.code;
                                                                  }
                                                              }

                                                              space.locales = [array.items valueForKey:@"dictionaryRepresentation"];

                                                              if (success) {
                                                                  success(response, space);
                                                              }
                                                          } failure:^(CDAResponse *response,
                                                                      NSError *error) {
                                                              if (response.statusCode == 404) {
                                                                  if (success) {
                                                                      success(response, space);
                                                                  }
                                                                  return;
                                                              }

                                                              if (failure) {
                                                                  failure(response, error);
                                                              }
                                                          }];
                             }
                             failure:failure];
}

-(CDARequest *)fetchUserWithSuccess:(CMAUserFetchedBlock)success failure:(CDARequestFailureBlock)failure {
    return [self.client fetchURLPath:@"user"
                          parameters:nil
                             success:success
                             failure:failure];
}

-(id)initWithAccessToken:(NSString *)accessToken configuration:(CDAConfiguration*)configuration {
    self = [super init];
    if (self) {
        // CMA is only accessible via HTTPS
        configuration.secure = YES;

        // Use the default server if the configuration has not been changed by the user
        if ([configuration.server isEqualToString:(NSString*)CDA_DEFAULT_SERVER]) {
            configuration.server = @"api.contentful.com";
        }

        if (!configuration.userAgent) {
            configuration.userAgent = @"contentful-management.objc/0.9.0";
        }

        self.client = [[CDAClient alloc] initWithSpaceKey:nil
                                              accessToken:accessToken
                                            configuration:configuration];
        self.client.resourceClassPrefix = @"CMA";

        // FIXME: Workaround for contentful/contentful.objc#46
        NSDictionary* dummyPayload = @{ @"sys": @{ @"id": @"06f5086772e0cd0b8f4e2381fa610d36" },
                                        @"name": @"yolo" };
        CDAContentType* dummyCT = [[CDAContentType alloc] initWithDictionary:dummyPayload
                                                                      client:self.client
                                                       localizationAvailable:NO];
        [self.client registerClass:CMAEntry.class forContentType:dummyCT];
    }
    return self;
}

-(id)initWithAccessToken:(NSString *)accessToken {
    return [self initWithAccessToken:accessToken configuration:[CDAConfiguration defaultConfiguration]];
}

@end
