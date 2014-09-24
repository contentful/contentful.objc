//
//  CDAClient.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAAsset.h>
#import <ContentfulDeliveryAPI/CDAEntry.h>
#import <ContentfulDeliveryAPI/CDASpace.h>

#import "CDAArray+Private.h"
#import "CDAClient+Private.h"
#import "CDAConfiguration+Private.h"
#import "CDAContentType.h"
#import "CDAContentTypeRegistry.h"
#import "CDAError+Private.h"
#import "CDARequestOperationManager.h"
#import "CDAResource+Private.h"
#import "CDASyncedSpace+Private.h"

NSString* const CDAContentTypeHeader = @"application/vnd.contentful.delivery.v1+json";
NSString* const CMAContentTypeHeader = @"application/vnd.contentful.management.v1+json";

@interface CDAClient ()

@property (nonatomic) NSString* accessToken;
@property (nonatomic) CDAConfiguration* configuration;
@property (nonatomic) CDAContentTypeRegistry* contentTypeRegistry;
@property (nonatomic) CDARequestOperationManager* requestOperationManager;
@property (nonatomic) CDASpace* space;
@property (nonatomic) NSString* spaceKey;

@end

#pragma mark -

@implementation CDAClient

// Terrible workaround to keep static builds from stripping these classes out.
+(void)load {
    NSArray* classes = @[ [CDAContentType class] ];
    classes = nil;
}

#pragma mark -

-(instancetype)copyWithSpace:(CDASpace *)space {
    CDAClient* client = [[[self class] alloc] initWithSpaceKey:space.identifier
                                                   accessToken:self.accessToken
                                                 configuration:self.configuration];
    client.resourceClassPrefix = self.resourceClassPrefix;
    client.space = space;
    return client;
}

-(CDARequest*)deleteURLPath:(NSString*)URLPath
                    headers:(NSDictionary*)headers
                 parameters:(NSDictionary*)parameters
                    success:(CDAObjectFetchedBlock)success
                    failure:(CDARequestFailureBlock)failure {
    return [self.requestOperationManager deleteURLPath:URLPath
                                               headers:headers
                                            parameters:parameters
                                               success:success
                                               failure:failure];
}

-(void)fetchAllItemsFromArray:(CDAArray*)array
                      success:(void (^)(NSArray* items))success
                      failure:(CDARequestFailureBlock)failure {
    [self fetchAllItemsFromArray:array
                intoMutableArray:[array.items mutableCopy]
                         success:success
                         failure:failure];
}

-(void)fetchAllItemsFromArray:(CDAArray*)array
             intoMutableArray:(NSMutableArray*)resultArray
                      success:(void (^)(NSArray* items))success
                      failure:(CDARequestFailureBlock)failure {
    CDARequest* request = [self fetchNextItemsFromArray:array
                                                success:^(CDAResponse *response, CDAArray *array) {
                                                    [resultArray addObjectsFromArray:array.items];
                                                    
                                                    [self fetchAllItemsFromArray:array
                                                                intoMutableArray:resultArray
                                                                         success:success
                                                                         failure:failure];
                                                } failure:failure];
    
    if (!request && success) {
        success([resultArray copy]);
    }
}

-(CDARequest*)fetchArrayAtURLPath:(NSString *)URLPath
                       parameters:(NSDictionary *)parameters
                          success:(CDAArrayFetchedBlock)success
                          failure:(CDARequestFailureBlock)failure {
    if (self.space || !self.spaceKey) {
        return [self.requestOperationManager fetchArrayAtURLPath:URLPath
                                                      parameters:parameters
                                                         success:success
                                                         failure:failure];
    } else {
        return [self fetchSpaceWithSuccess:^(CDAResponse *response, CDASpace *space) {
            [self.requestOperationManager fetchArrayAtURLPath:URLPath
                                                   parameters:parameters
                                                      success:success
                                                      failure:failure];
        } failure:failure];
    }
}

-(CDARequest*)fetchArrayAtURLPath:(NSString *)URLPath
                          success:(CDAArrayFetchedBlock)success
                          failure:(CDARequestFailureBlock)failure {
    return [self fetchArrayAtURLPath:URLPath parameters:nil success:success failure:failure];
}

-(CDARequest*)fetchAssetsMatching:(NSDictionary*)query
                          success:(CDAArrayFetchedBlock)success
                          failure:(CDARequestFailureBlock)failure {
    return [self fetchArrayAtURLPath:@"assets"
                          parameters:query
                             success:success
                             failure:failure];
}

-(CDAArray *)fetchAssetsMatching:(NSDictionary *)query synchronouslyWithError:(NSError * __autoreleasing *)error {
    return [self.requestOperationManager fetchArraySynchronouslyAtURLPath:@"assets"
                                                               parameters:query
                                                                    error:error];
}

-(CDARequest*)fetchAssetsWithSuccess:(CDAArrayFetchedBlock)success
                             failure:(CDARequestFailureBlock)failure {
    return [self fetchArrayAtURLPath:@"assets" success:success failure:failure];
}

-(CDARequest*)fetchAssetWithIdentifier:(NSString *)identifier
                               success:(CDAAssetFetchedBlock)success
                               failure:(CDARequestFailureBlock)failure {
    return [self fetchAssetsMatching:@{ @"sys.id": identifier }
                             success:^(CDAResponse *response, CDAArray *array) {
                                 if (array.items.count == 0) {
                                     if (failure) {
                                         failure(response, [CDAError buildErrorWithCode:0 userInfo:@{ NSLocalizedDescriptionKey: @"No Resources matched your query." }]);
                                     }
                                     
                                     return;
                                 }
                                 
                                 if (success) {
                                     NSAssert(array.items.count == 1,
                                              @"Should have only one item.");
                                     success(response, [array.items firstObject]);
                                 }
                             } failure:failure];
}

-(CDAArray*)fetchContentTypesMatching:(NSDictionary*)query synchronouslyWithError:(NSError* __autoreleasing *)error {
    return [self.requestOperationManager fetchArraySynchronouslyAtURLPath:@"content_types"
                                                               parameters:query
                                                                    error:error];
}

-(CDARequest*)fetchContentTypesWithSuccess:(CDAArrayFetchedBlock)success
                                   failure:(CDARequestFailureBlock)failure {
    return [self fetchArrayAtURLPath:@"content_types" success:success failure:failure];
}

-(CDARequest*)fetchContentTypeWithIdentifier:(NSString *)identifier
                                     success:(CDAContentTypeFetchedBlock)success
                                     failure:(CDARequestFailureBlock)failure {
    return [self fetchArrayAtURLPath:@"content_types" parameters:@{ @"sys.id": identifier }
                             success:^(CDAResponse *response, CDAArray *array) {
                                 if (array.items.count == 0) {
                                     if (failure) {
                                         failure(response, [CDAError buildErrorWithCode:0 userInfo:@{ NSLocalizedDescriptionKey: @"No Resources matched your query." }]);
                                     }
                                     
                                     return;
                                 }
                                 
                                 if (success) {
                                     NSAssert(array.items.count == 1,
                                              @"Should have only one item.");
                                     success(response, [array.items firstObject]);
                                 }
                             } failure:failure];
}

-(CDARequest*)fetchEntriesMatching:(NSDictionary *)query
                           success:(CDAArrayFetchedBlock)success
                           failure:(CDARequestFailureBlock)failure {
    return [self fetchArrayAtURLPath:@"entries" parameters:query success:success failure:failure];
}

-(CDAArray *)fetchEntriesMatching:(NSDictionary *)query synchronouslyWithError:(NSError * __autoreleasing *)error {
    return [self.requestOperationManager fetchArraySynchronouslyAtURLPath:@"entries"
                                                               parameters:query
                                                                    error:error];
}

-(CDARequest*)fetchEntriesWithSuccess:(CDAArrayFetchedBlock)success
                              failure:(CDARequestFailureBlock)failure {
    return [self fetchArrayAtURLPath:@"entries" success:success failure:failure];
}

-(CDARequest*)fetchEntryWithIdentifier:(NSString *)identifier
                               success:(CDAEntryFetchedBlock)success
                               failure:(CDARequestFailureBlock)failure {
    return [self fetchEntriesMatching:@{ @"sys.id": identifier }
                              success:^(CDAResponse *response, CDAArray *array) {
                                  if (array.items.count == 0) {
                                      if (failure) {
                                          failure(response, [CDAError buildErrorWithCode:0 userInfo:@{ NSLocalizedDescriptionKey: @"No Resources matched your query." }]);
                                      }
                                      
                                      return;
                                  }
                                  
                                  NSAssert(array.items.count == 1, @"Should only have one entry.");
                                  if (success) {
                                      success(response, [array.items firstObject]);
                                  }
                              } failure:failure];
}

-(CDARequest*)fetchNextItemsFromArray:(CDAArray*)array
                              success:(CDAArrayFetchedBlock)success
                              failure:(CDARequestFailureBlock)failure {
    NSAssert(array.query, @"Query parameters missing from array.");
    
    if (array.skip + array.limit >= array.total) {
        return nil;
    }
    
    NSMutableDictionary* query = [array.query mutableCopy];
    query[@"skip"] = @(array.skip + array.limit);
    
    if ([[array.items firstObject] isKindOfClass:[CDAAsset class]]) {
        return [self fetchAssetsMatching:query success:success failure:failure];
    } else {
        NSAssert([[array.items firstObject] isKindOfClass:[CDAEntry class]],
                 @"Array need to contain either assets or entries.");
        return [self fetchEntriesMatching:query success:success failure:failure];
    }
}

-(CDARequest *)fetchResourcesOfType:(CDAResourceType)resourceType
                           matching:(NSDictionary *)query
                            success:(CDAArrayFetchedBlock)success
                            failure:(CDARequestFailureBlock)failure {
    switch (resourceType) {
        case CDAResourceTypeAsset:
            return [self fetchAssetsMatching:query success:success failure:failure];
        case CDAResourceTypeContentType:
            return [self fetchContentTypesWithSuccess:success failure:failure];
        case CDAResourceTypeEntry:
            return [self fetchEntriesMatching:query success:success failure:failure];
    }
}

-(CDARequest*)fetchSpaceWithSuccess:(CDASpaceFetchedBlock)success
                            failure:(CDARequestFailureBlock)failure {
    if (self.space) {
        if (success) {
            success(nil, self.space);
        }
        
        return nil;
    }
    
    return [self.requestOperationManager fetchSpaceWithSuccess:^(CDAResponse *response,
                                                                 CDASpace *space) {
        self.space = space;
        
        if (success) {
            success(response, space);
        }
    } failure:failure];
}

-(CDARequest *)fetchURLPath:(NSString *)URLPath
                 parameters:(NSDictionary *)parameters
                    success:(CDAObjectFetchedBlock)success
                    failure:(CDARequestFailureBlock)failure {
    return [self.requestOperationManager fetchURLPath:URLPath
                                           parameters:parameters
                                              success:success
                                              failure:failure];
}

-(CDARequest*)initialSynchronizationWithSuccess:(CDASyncedSpaceFetchedBlock)success
                                        failure:(CDARequestFailureBlock)failure {
    return [self initialSynchronizationMatching:nil success:success failure:failure];
}

-(CDARequest *)initialSynchronizationMatching:(NSDictionary *)query
                                      success:(CDASyncedSpaceFetchedBlock)success
                                      failure:(CDARequestFailureBlock)failure {
    if (self.configuration.previewMode) {
        void(^handler)(NSArray* fetchedAssets, NSArray* fetchedEntries) = ^(NSArray* fetchedAssets,
                                                                            NSArray* fetchedEntries) {
            NSMutableDictionary* assets = [@{} mutableCopy];
            NSMutableDictionary* entries = [@{} mutableCopy];
            
            for (CDAAsset* asset in fetchedAssets) {
                assets[asset.identifier] = asset;
            }
            
            for (CDAEntry* entry in fetchedEntries) {
                entries[entry.identifier] = entry;
            }
            
            for (CDAEntry* entry in entries.allValues) {
                [entry resolveLinksWithIncludedAssets:assets entries:entries];
            }
            
            CDASyncedSpace* space = [[CDASyncedSpace alloc] initWithAssets:assets.allValues
                                                                   entries:entries.allValues];
            
            space.client = self;
            success(nil, space);
        };
        
        return [self fetchAssetsWithSuccess:^(CDAResponse *response, CDAArray *array) {
            [self fetchAllItemsFromArray:array success:^(NSArray *fetchedAssets) {
                [self fetchEntriesWithSuccess:^(CDAResponse *response, CDAArray *array) {
                    [self fetchAllItemsFromArray:array success:^(NSArray *fetchedEntries) {
                        handler(fetchedAssets, fetchedEntries);
                    } failure:failure];
                } failure:failure];
            } failure:failure];
        } failure:failure];
    }
    
    CDAArrayFetchedBlock handler = ^(CDAResponse *response, CDAArray *array) {
        NSMutableDictionary* assets = [@{} mutableCopy];
        NSMutableDictionary* entries = [@{} mutableCopy];
        
        for (CDAResource* resource in array.items) {
            if ([resource isKindOfClass:[CDAAsset class]]) {
                assets[resource.identifier] = resource;
            }
            
            if ([resource isKindOfClass:[CDAEntry class]]) {
                entries[resource.identifier] = resource;
            }
        }
        
        for (CDAEntry* entry in entries.allValues) {
            [entry resolveLinksWithIncludedAssets:assets entries:entries];
        }
        
        CDASyncedSpace* space = [[CDASyncedSpace alloc] initWithAssets:assets.allValues
                                                               entries:entries.allValues];
        
        space.client = self;
        space.nextPageUrl = array.nextPageUrl;
        space.nextSyncUrl = array.nextSyncUrl;
        
        if (success) {
            if (space.nextPageUrl) {
                [space performSynchronizationWithSuccess:^{
                    success(response, space);
                } failure:failure];
            } else {
                [space updateLastSyncTimestamp];
                
                success(response, space);
            }
        }
    };
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithDictionary:query];
    parameters[@"initial"] = @"true";
    
    return [self fetchArrayAtURLPath:@"sync"
                          parameters:parameters
                             success:handler
                             failure:failure];
}

-(id)init {
    return [self initWithSpaceKey:@"cfexampleapi" accessToken:@"b4c0n73n7fu1"];
}

-(id)initWithSpaceKey:(NSString *)spaceKey accessToken:(NSString *)accessToken {
    return [self initWithSpaceKey:spaceKey
                      accessToken:accessToken
                    configuration:[CDAConfiguration defaultConfiguration]];
}

-(id)initWithSpaceKey:(NSString *)spaceKey
          accessToken:(NSString *)accessToken
        configuration:(CDAConfiguration*)configuration {
    if (!configuration.usesManagementAPI && (configuration.previewMode || !spaceKey)) {
        configuration.usesManagementAPI = YES;
    }

    self = [super init];
    if (self) {
        self.accessToken = accessToken;
        self.configuration = configuration;
        self.contentTypeRegistry = [CDAContentTypeRegistry new];
        self.deepResolving = YES;
        self.spaceKey = spaceKey;
        self.requestOperationManager = [[CDARequestOperationManager alloc] initWithSpaceKey:spaceKey accessToken:accessToken client:self configuration:configuration];
        self.resourceClassPrefix = @"CDA";

#ifndef DEBUG
        if (self.configuration.previewMode) {
            [[NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:@"You are using the preview-mode in a release-build"
                                   userInfo:@{}] raise];
        }
#endif
    }
    return self;
}

-(BOOL)localizationAvailable {
    return self.configuration.usesManagementAPI || self.synchronizing;
}

-(CDARequest *)postURLPath:(NSString *)URLPath
                   headers:(NSDictionary *)headers
                parameters:(NSDictionary *)parameters
                   success:(CDAObjectFetchedBlock)success
                   failure:(CDARequestFailureBlock)failure {
    return [self.requestOperationManager postURLPath:URLPath
                                             headers:headers
                                          parameters:parameters
                                             success:success
                                             failure:failure];
}

-(NSString *)protocol {
    return self.configuration.secure ? @"https" : @"http";
}

-(CDARequest*)putURLPath:(NSString*)URLPath
                 headers:(NSDictionary*)headers
              parameters:(NSDictionary*)parameters
                 success:(CDAObjectFetchedBlock)success
                 failure:(CDARequestFailureBlock)failure {
    return [self.requestOperationManager putURLPath:URLPath
                                            headers:headers
                                         parameters:parameters
                                            success:success
                                            failure:failure];
}

-(void)registerClass:(Class)customClass forContentType:(CDAContentType *)contentType {
    [self.contentTypeRegistry registerClass:customClass forContentType:contentType];
}

-(void)registerClass:(Class)customClass forContentTypeWithIdentifier:(NSString *)identifier {
    [self.contentTypeRegistry registerClass:customClass forContentTypeWithIdentifier:identifier];
}

-(void)resolveLinkAtIndex:(NSUInteger)index
                fromArray:(NSArray*)fromArray
                  toArray:(NSMutableArray*)toArray
                  success:(void (^)(NSArray* items))success
                  failure:(CDARequestFailureBlock)failure {
    if (index >= fromArray.count) {
        if (success) {
            success([toArray copy]);
        }
        
        return;
    }
    
    CDAResource* currentResource = fromArray[index];
    [currentResource resolveWithSuccess:^(CDAResponse *response, CDAResource *resource) {
        [toArray addObject:resource];
        
        [self resolveLinkAtIndex:index + 1
                       fromArray:fromArray
                         toArray:toArray
                         success:success
                         failure:failure];
    } failure:failure];
}

-(void)resolveLinksFromArray:(NSArray*)array
                     success:(void (^)(NSArray* items))success
                     failure:(CDARequestFailureBlock)failure {
    if (![[array firstObject] isKindOfClass:[CDAResource class]]) {
        if (success) {
            success(array);
        }
        
        return;
    }
    
    [self resolveLinkAtIndex:0
                   fromArray:array
                     toArray:[@[] mutableCopy]
                     success:success
                     failure:failure];
}

@end
