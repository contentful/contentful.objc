//
//  CMASpace.m
//  ManagementSDK
//
//  Created by Boris Bügling on 15/07/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import "CDAClient+Private.h"
#import "CDAResource+Management.h"
#import "CMASpace+Private.h"
#import "CMAUtilities.h"
#import "CMAWebhook+Private.h"
#import "CDARequestOperationManager.h"
#import "CMAContentType.h"

@interface CMASpace ()

@property (nonatomic) CDAClient* apiClient;;

@end

#pragma mark -

@implementation CMASpace

@dynamic name;

#pragma mark -

+(NSString*)determineMIMETypeOfResourceAtURL:(NSURL*)url
                                       error:(NSError*__autoreleasing *)error {

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"HEAD";

    NSHTTPURLResponse* response;
    NSData* data = [CDARequestOperationManager sendSynchronousRequest:[request copy]
                                                    returningResponse:&response
                                                                error:error];

    if (!data) {
        return @"application/octet-stream";
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.allHeaderFields[@"Content-Type"];
    }

    return @"application/octet-stream";
}

+(NSDictionary*)fileUploadDictionaryFromLocalizedUploads:(NSDictionary*)localizedUploads {
    NSMutableDictionary* fileDictionary = [@{} mutableCopy];

    [localizedUploads enumerateKeysAndObjectsUsingBlock:^(NSString* language,
                                                          NSString* fileUrl,
                                                          BOOL *stop) {
        NSString* mimeType = [[self class] determineMIMETypeOfResourceAtURL:[NSURL URLWithString:fileUrl]
                                                                      error:nil];

        fileDictionary[language] = @{ @"upload": fileUrl,
                                      @"contentType": mimeType,
                                      @"fileName": [fileUrl lastPathComponent] };
    }];

    return fileDictionary;
}

#pragma mark -

-(CDAClient *)client {
    return self.apiClient;
}

-(void)setClient:(CDAClient *)client {
    NSParameterAssert(client);
    self.apiClient = [client copyWithSpace:self];
}

-(CDARequest *)createAssetWithFields:(NSDictionary *)fields
                             success:(CMAAssetFetchedBlock)success
                             failure:(CDARequestFailureBlock)failure {
    NSParameterAssert(self.client);
    return [self.client postURLPath:@"assets"
                            headers:nil
                         parameters:@{ @"fields": fields }
                            success:^(CDAResponse *response, id responseObject) {
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                                               dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                                               ^{
                                                   if (success) {
                                                       success(response, responseObject);
                                                   }
                                               });

                            } failure:failure];
}

-(CDARequest *)createAssetWithIdentifier:(NSString*)identifier
                                  fields:(NSDictionary *)fields
                                 success:(CMAAssetFetchedBlock)success
                                 failure:(CDARequestFailureBlock)failure {
    NSParameterAssert(self.client);
    return [self.client putURLPath:[@"assets" stringByAppendingPathComponent:identifier]
                           headers:nil
                        parameters:@{ @"fields": fields }
                           success:^(CDAResponse *response, id responseObject) {
                               dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                                              dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                                              ^{
                                                  if (success) {
                                                      success(response, responseObject);
                                                  }
                                              });

                           } failure:failure];
}

-(void)createAssetWithTitle:(NSDictionary *)titleDictionary
                description:(NSDictionary *)descriptionDictionary
               fileToUpload:(NSDictionary *)fileUploadDictionary
                    success:(CMAAssetFetchedBlock)success
                    failure:(CDARequestFailureBlock)failure {
    NSMutableDictionary* fields = [@{} mutableCopy];

    if (titleDictionary.count > 0) {
        fields[@"title"] = titleDictionary;
    }

    if (descriptionDictionary.count > 0) {
        fields[@"description"] = descriptionDictionary;
    }

    if (fileUploadDictionary.count == 0) {
        [self createAssetWithFields:[fields copy] success:success failure:failure];
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        fields[@"file"] = [[self class] fileUploadDictionaryFromLocalizedUploads:fileUploadDictionary];
        [self createAssetWithFields:[fields copy] success:success failure:failure];
    });
}

-(CDARequest *)createContentTypeWithName:(NSString*)name
                                  fields:(NSArray*)fields
                                 success:(CMAContentTypeFetchedBlock)success
                                 failure:(CDARequestFailureBlock)failure {
    NSParameterAssert(self.client);

    NSArray* fieldsAsDictionaries = fields ? [fields valueForKey:@"dictionaryRepresentation"] : @[];

    return [self.client postURLPath:@"content_types"
                            headers:nil
                         parameters:@{ @"name": name, @"fields": fieldsAsDictionaries }
                            success:success
                            failure:failure];
}

-(CDARequest *)createEntryOfContentType:(CMAContentType*)contentType
                             withFields:(NSDictionary *)fields
                                success:(CMAEntryFetchedBlock)success
                                failure:(CDARequestFailureBlock)failure {
    NSParameterAssert(self.client);
    return [self.client postURLPath:@"entries"
                            headers:@{ @"X-Contentful-Content-Type": contentType.identifier }
                         parameters:@{ @"fields": CMASanitizeParameterDictionaryForJSON(fields) }
                            success:^(CDAResponse *response, id responseObject) {
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                                               dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                                               ^{
                                                   if (success) {
                                                       success(response, responseObject);
                                                   }
                                               });

                            } failure:failure];
}

-(CDARequest *)createEntryOfContentType:(CMAContentType *)contentType
                         withIdentifier:(NSString *)identifier
                                 fields:(NSDictionary *)fields
                                success:(CMAEntryFetchedBlock)success
                                failure:(CDARequestFailureBlock)failure {
    NSParameterAssert(self.client);
    return [self.client putURLPath:[@"entries" stringByAppendingPathComponent:identifier]
                           headers:@{ @"X-Contentful-Content-Type": contentType.identifier }
                        parameters:@{ @"fields": fields }
                           success:^(CDAResponse *response, id responseObject) {
                               dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                                              dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                                              ^{
                                                  if (success) {
                                                      success(response, responseObject);
                                                  }
                                              });

                           } failure:failure];
}

-(CDARequest *)createLocaleWithName:(NSString *)name
                               code:(NSString *)code
                            success:(CMALocaleFetchedBlock)success
                            failure:(CDARequestFailureBlock)failure {
    NSParameterAssert(self.client);
    return [self.client postURLPath:@"locales"
                            headers:nil
                         parameters:@{ @"name": name, @"code": code }
                            success:success
                            failure:failure];
}

-(CDARequest *)createRoleWithName:(NSString *)name
                      description:(NSString *)description
                      permissions:(NSDictionary *)permissions
                         policies:(NSArray *)policies
                          success:(CMARoleFetchedBlock)success
                          failure:(CDARequestFailureBlock)failure {
    NSParameterAssert(self.client);
    return [self.client postURLPath:@"roles"
                            headers:nil
                         parameters:@{ @"name": name, @"description": description,
                                       @"permissions": permissions, @"policies": policies }
                            success:success
                            failure:failure];
}

-(CDARequest *)createWebhookWithName:(NSString*)name
                                 url:(NSURL*)url
                              topics:(NSArray*)topics
                             headers:(NSDictionary*)headers
                   httpBasicUsername:(NSString*)httpBasicUsername
                   httpBasicPassword:(NSString*)httpBasicPassword
                             success:(CMAWebhookFetchedBlock)success
                             failure:(CDARequestFailureBlock)failure {
    NSDictionary* parameters = [CMAWebhook parametersForWebhookWithName:name
                                                                    url:url
                                                                 topics:topics
                                                                headers:headers
                                                      httpBasicUsername:httpBasicUsername
                                                      httpBasicPassword:httpBasicPassword];

    NSParameterAssert(self.client);
    return [self.client postURLPath:@"webhook_definitions"
                            headers:nil
                         parameters:parameters
                            success:success
                            failure:failure];
}

-(CDARequest *)deleteWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure {
    return [self performDeleteToFragment:@"" withSuccess:success failure:failure];
}

-(CDARequest *)fetchAssetsMatching:(NSDictionary *)query
                           success:(CDAArrayFetchedBlock)success
                           failure:(CDARequestFailureBlock)failure {
    NSParameterAssert(self.client);
    return [self.client fetchAssetsMatching:query
                                    success:success
                                    failure:failure];
}

-(CDARequest *)fetchAccessTokensWithSuccess:(CDAArrayFetchedBlock)success
                                    failure:(CDARequestFailureBlock)failure {
    NSParameterAssert(self.client);
    return [self.client fetchArrayAtURLPath:@"api_keys" parameters:nil success:success failure:failure];
}

-(CDARequest *)fetchAssetsWithSuccess:(CDAArrayFetchedBlock)success
                              failure:(CDARequestFailureBlock)failure {
    NSParameterAssert(self.client);
    return [self.client fetchAssetsWithSuccess:success failure:failure];
}

-(CDARequest *)fetchAssetWithIdentifier:(NSString *)identifier
                                success:(CMAAssetFetchedBlock)success
                                failure:(CDARequestFailureBlock)failure {
    NSParameterAssert(self.client);
    return [self.client fetchAssetWithIdentifier:identifier
                                         success:^(CDAResponse *response, CDAAsset *asset) {
                                             if (success) {
                                                 success(response, (CMAAsset*)asset);
                                             }
                                         } failure:failure];
}

-(CDARequest *)fetchContentTypesWithSuccess:(CDAArrayFetchedBlock)success
                                    failure:(CDARequestFailureBlock)failure {
    NSParameterAssert(self.client);
    return [self.client fetchContentTypesWithSuccess:success failure:failure];
}

-(CDARequest *)fetchContentTypeWithIdentifier:(NSString *)identifier
                                      success:(CMAContentTypeFetchedBlock)success
                                      failure:(CDARequestFailureBlock)failure {
    NSParameterAssert(self.client);
    return [self.client fetchContentTypeWithIdentifier:identifier
                                               success:^(CDAResponse *response,
                                                         CDAContentType *contentType) {
                                                   if (success) {
                                                       success(response, (CMAContentType*)contentType);
                                                   }
                                               } failure:failure];
}

-(CDARequest *)fetchEntriesMatching:(NSDictionary *)query
                            success:(CDAArrayFetchedBlock)success
                            failure:(CDARequestFailureBlock)failure {
    NSParameterAssert(self.client);
    return [self.client fetchEntriesMatching:query
                                     success:success
                                     failure:failure];
}

-(CDARequest *)fetchEntriesWithSuccess:(CDAArrayFetchedBlock)success
                               failure:(CDARequestFailureBlock)failure {
    NSParameterAssert(self.client);
    return [self.client fetchEntriesWithSuccess:success failure:failure];
}

-(CDARequest *)fetchEntryWithIdentifier:(NSString *)identifier
                                success:(CDAEntryFetchedBlock)success
                                failure:(CDARequestFailureBlock)failure {
    NSParameterAssert(self.client);
    return [self.client fetchEntryWithIdentifier:identifier success:success failure:failure];
}

-(CDARequest *)fetchPublishedContentTypesWithSuccess:(CDAArrayFetchedBlock)success
                                             failure:(CDARequestFailureBlock)failure {
    NSParameterAssert(self.client);
    return [self.client fetchArrayAtURLPath:@"public/content_types"
                                 parameters:@{}
                                    success:success
                                    failure:failure];
}

-(CDARequest *)fetchRolesMatching:(NSDictionary *)query
                      withSuccess:(CDAArrayFetchedBlock)success
                          failure:(CDARequestFailureBlock)failure {
    NSParameterAssert(self.client);
    return [self.client fetchArrayAtURLPath:@"roles"
                                 parameters:query
                                    success:success
                                    failure:failure];
}

-(CDARequest *)fetchRoleWithIdentifier:(NSString *)identifier
                               success:(CMARoleFetchedBlock)success
                               failure:(CDARequestFailureBlock)failure {
    NSParameterAssert(self.client);
    return [self.client fetchURLPath:[@"roles" stringByAppendingPathComponent:identifier]
                          parameters:@{}
                             success:success
                             failure:failure];
}

-(CDARequest *)fetchWebhookWithIdentifier:(NSString*)identifier
                                  success:(CMAWebhookFetchedBlock)success
                                  failure:(CDARequestFailureBlock)failure {
    NSParameterAssert(self.client);
    return [self.client fetchURLPath:[@"webhook_definitions" stringByAppendingPathComponent:identifier]
                          parameters:@{}
                             success:success
                             failure:failure];
}

-(CDARequest *)fetchWebhooksWithSuccess:(CDAArrayFetchedBlock)success
                                failure:(CDARequestFailureBlock)failure {
    NSParameterAssert(self.client);
    return [self.client fetchArrayAtURLPath:@"webhook_definitions"
                                 parameters:@{}
                                    success:success
                                    failure:failure];
}

-(CDARequest *)updateWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure {
    return [self performPutToFragment:@""
                       withParameters:@{ @"name": self.name }
                              success:success
                              failure:failure];
}

-(NSString *)URLPath {
    return @"";
}

@end
