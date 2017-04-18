//
//  CMASpace.h
//  ManagementSDK
//
//  Created by Boris Bügling on 15/07/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <ContentfulDeliveryAPI/CDANullabilityStubs.h>
#import <ContentfulManagementAPI/ContentfulManagementAPI.h>

NS_ASSUME_NONNULL_BEGIN

@class CMAContentType;

/**
 *  Management extensions for spaces.
 */
@interface CMASpace : CDASpace <CMAResource>

/**
 *  The name of the receiver.
 */
@property (nonatomic) NSString* name;

/**
 *  Create a new asset on Contentful.
 *
 *  @param titleDictionary          Localized values for the asset title.
 *  @param descriptionDictionary    Localized values for the asset description.
 *  @param fileUploadDictionary     Localized values for the file to upload.
 *  @param success                  Called if creation succeeds.
 *  @param failure                  Called if creation fails.
 */
-(void)createAssetWithTitle:(NSDictionary* __nullable)titleDictionary
                description:(NSDictionary* __nullable)descriptionDictionary
               fileToUpload:(NSDictionary* __nullable)fileUploadDictionary
                    success:(CMAAssetFetchedBlock)success
                    failure:(CDARequestFailureBlock)failure;

/**
 *  Create a new content type on Contentful.
 *
 *  @param name    The name for the new content type.
 *  @param fields  The fields for the new content type.
 *  @param success Called if creation succeeds.
 *  @param failure Called if creation fails.
 *
 *  @return The request used for creation.
 */
-(CDARequest*)createContentTypeWithName:(NSString*)name
                                 fields:(NSArray* __nullable)fields
                                success:(CMAContentTypeFetchedBlock)success
                                failure:(CDARequestFailureBlock)failure;

/**
 *  Create a new entry on Contentful.
 *
 *  @param contentType The content type for the new entry.
 *  @param fields      The field values for the new entry.
 *  @param success     Called if creation succeeds.
 *  @param failure     Called if creation fails.
 *
 *  @return The request used for creation.
 */
-(CDARequest*)createEntryOfContentType:(CMAContentType*)contentType
                            withFields:(NSDictionary*)fields
                               success:(CMAEntryFetchedBlock)success
                               failure:(CDARequestFailureBlock)failure;

/**
 *  Create a new locale on Contentful.
 *
 *  @param name    The name for the new locale.
 *  @param code    The code for the new locale.
 *  @param success Called if creation succeeds.
 *  @param failure Called if creation fails.
 *
 *  @return The request used for creation.
 */
-(CDARequest*)createLocaleWithName:(NSString*)name
                              code:(NSString*)code
                           success:(CMALocaleFetchedBlock)success
                           failure:(CDARequestFailureBlock)failure;

/**
 *  Create a new role on Contentful.
 *
 *  @param name         The name for the new role.
 *  @param description  The description of the new role.
 *  @param permissions  The permissions of the new role.
 *  @param policies     The policies of the new role.
 *  @param success Called if creation succeeds.
 *  @param failure Called if creation fails.
 *
 *  @return The request used for creation.
 */
-(CDARequest *)createRoleWithName:(NSString *)name
                      description:(NSString *)description
                      permissions:(NSDictionary *)permissions
                         policies:(NSArray *)policies
                          success:(CMARoleFetchedBlock)success
                          failure:(CDARequestFailureBlock)failure;

/**
 *  Create a new webhook on Contentful.
 *
 *  @param name                 The name for the new role.
 *  @param url                  The URL to request when the webhook is triggered.
 *  @param topics               The events for which the webhook will be triggered.
 *  @param headers              Additional headers to send with the webhook request.
 *  @param httpBasicUsername    HTTP basic auth username to send with the webhook request.
 *  @param httpBasicPassword    HTTP basic auth password to send with the webhook request.
 *  @param success              Called if creation succeeds.
 *  @param failure              Called if creation fails.
 *
 *  @return The request used for creation.
 */
-(CDARequest *)createWebhookWithName:(NSString*)name
                                 url:(NSURL*)url
                              topics:(NSArray* __nullable)topics
                             headers:(NSDictionary* __nullable)headers
                   httpBasicUsername:(NSString* __nullable)httpBasicUsername
                   httpBasicPassword:(NSString* __nullable)httpBasicPassword
                             success:(CMAWebhookFetchedBlock)success
                             failure:(CDARequestFailureBlock)failure;

/**
 *  Fetch all Access Tokens from the server.
 *
 *  @param success A block which gets called upon successful retrieval of all Access Tokens.
 *  @param failure A block which gets called if an error occured during the retrieval process.
 *  @return The request used for fetching data.
 */
-(CDARequest*)fetchAccessTokensWithSuccess:(CDAArrayFetchedBlock)success
                                   failure:(CDARequestFailureBlock)failure;

/**
 *  Fetch all Assets matching a query from the server.
 *
 *  @param query   The query which retrieved Assets shall match. Queries are expressed as dictionaries,
 *                 see [Search Parameters](https://www.contentful.com/developers/documentation/content-delivery-api/#search) for more information.
 *  @param success A block which gets called upon successful retrieval of all matching Assets.
 *  @param failure A block which gets called if an error occured during the retrieval process.
 *  @return The request used for fetching data.
 */
-(CDARequest*)fetchAssetsMatching:(NSDictionary* __nullable)query
                          success:(CDAArrayFetchedBlock)success
                          failure:(CDARequestFailureBlock)failure;

/**
 *  Fetch all Assets from the server.
 *
 *  @param success A block which gets called upon successful retrieval of all Assets.
 *  @param failure A block which gets called if an error occured during the retrieval process.
 *  @return The request used for fetching data.
 */
-(CDARequest*)fetchAssetsWithSuccess:(CDAArrayFetchedBlock)success
                             failure:(CDARequestFailureBlock)failure;

/**
 *  Fetch a single asset from Contentful.
 *
 *  @param identifier The identifier of the asset to fetch.
 *  @param success    Called if fetching succeeds.
 *  @param failure    Called if fetching fails.
 *
 *  @return The request used for fetching data.
 */
-(CDARequest*)fetchAssetWithIdentifier:(NSString*)identifier
                               success:(CMAAssetFetchedBlock)success
                               failure:(CDARequestFailureBlock)failure;

/**
 *  Fetch all content types from Contentful.
 *
 *  @param success Called if fetching succeeds.
 *  @param failure Called if fetching fails.
 *
 *  @return The request used for fetching data.
 */
-(CDARequest*)fetchContentTypesWithSuccess:(CDAArrayFetchedBlock)success
                                   failure:(CDARequestFailureBlock)failure;

/**
 *  Fetch a single content type from Contentful.
 *
 *  @param identifier The identifier of the content type to fetch.
 *  @param success    Called if fetching succeeds.
 *  @param failure    Called if fetching fails.
 *
 *  @return The request used for fetching data.
 */
-(CDARequest*)fetchContentTypeWithIdentifier:(NSString*)identifier
                                     success:(CMAContentTypeFetchedBlock)success
                                     failure:(CDARequestFailureBlock)failure;

/**
 *  Fetch all Entries matching a query from the server.
 *
 *  @param query   The query which retrieved Entries shall match. Queries are expressed as dictionaries,
 *                 see [Search Parameters](https://www.contentful.com/developers/documentation/content-delivery-api/#search) for more information.
 *  @param success A block which gets called upon successful retrieval of all matching Entries.
 *  @param failure A block which gets called if an error occured during the retrieval process.
 *  @return The request used for fetching data.
 */
-(CDARequest*)fetchEntriesMatching:(NSDictionary* __nullable)query
                           success:(CDAArrayFetchedBlock)success
                           failure:(CDARequestFailureBlock)failure;

/**
 *  Fetch all Entries from the server.
 *
 *  @param success A block which gets called upon successful retrieval of all Entries.
 *  @param failure A block which gets called if an error occured during the retrieval process.
 *  @return The request used for fetching data.
 */
-(CDARequest*)fetchEntriesWithSuccess:(CDAArrayFetchedBlock)success
                              failure:(CDARequestFailureBlock)failure;

/**
 *  Fetch a single entry from Contentful.
 *
 *  @param identifier The identifier of the entry to fetch.
 *  @param success    Called if fetching succeeds.
 *  @param failure    Called if fetching fails.
 *
 *  @return The request used for fetching data.
 */
-(CDARequest*)fetchEntryWithIdentifier:(NSString*)identifier
                               success:(CDAEntryFetchedBlock)success
                               failure:(CDARequestFailureBlock)failure;

/**
 *  Fetch all published Content Types from Contentful.
 *
 *  @param success Called if fetching succeeds.
 *  @param failure Called if fetching fails.
 *
 *  @return The request used for fetching data.
 */
-(CDARequest*)fetchPublishedContentTypesWithSuccess:(CDAArrayFetchedBlock)success
                                            failure:(CDARequestFailureBlock)failure;

/**
 *  Fetch all matching roles from Contentful.
 *
 *  @param query    Query parameters for pagination of roles collection.
 *  @param success  Called if fetching succeeds.
 *  @param failure  Called if fetching fails.
 *
 *  @return The request used for fetching data.
 */
-(CDARequest *)fetchRolesMatching:(NSDictionary* __nullable)query
                      withSuccess:(CDAArrayFetchedBlock)success
                          failure:(CDARequestFailureBlock)failure;

/**
 *  Fetch a single role from Contentful.
 *
 *  @param identifier   Identifier of the role to be requested.
 *  @param success      Called if fetching succeeds.
 *  @param failure      Called if fetching fails.
 *
 *  @return The request used for fetching data.
 */
-(CDARequest *)fetchRoleWithIdentifier:(NSString *)identifier
                               success:(CMARoleFetchedBlock)success
                               failure:(CDARequestFailureBlock)failure;

/**
 *  Fetch a single webhook from Contentful.
 *
 *  @param identifier   Identifier of the webhook to be requested.
 *  @param success      Called if fetching succeeds.
 *  @param failure      Called if fetching fails.
 *
 *  @return The request used for fetching data.
 */
-(CDARequest *)fetchWebhookWithIdentifier:(NSString*)identifier
                                  success:(CMAWebhookFetchedBlock)success
                                  failure:(CDARequestFailureBlock)failure;

/**
 *  Fetch all webhooks from Contentful.
 *
 *  @param success      Called if fetching succeeds.
 *  @param failure      Called if fetching fails.
 *
 *  @return The request used for fetching data.
 */
-(CDARequest *)fetchWebhooksWithSuccess:(CDAArrayFetchedBlock)success
                                failure:(CDARequestFailureBlock)failure;

@end

NS_ASSUME_NONNULL_END
