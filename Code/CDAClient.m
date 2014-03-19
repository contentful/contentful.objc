//
//  CDAClient.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAAsset.h>
#import <ContentfulDeliveryAPI/CDAEntry.h>
#import <ISO8601DateFormatter/ISO8601DateFormatter.h>

#import "CDAArray+Private.h"
#import "CDAClient+Private.h"
#import "CDAConfiguration.h"
#import "CDAContentType.h"
#import "CDAContentTypeRegistry.h"
#import "CDAError.h"
#import "CDARequestOperationManager.h"

@interface CDAClient ()

@property (nonatomic) CDAConfiguration* configuration;
@property (nonatomic) CDAContentTypeRegistry* contentTypeRegistry;
@property (nonatomic) ISO8601DateFormatter* dateFormatter;
@property (nonatomic) CDARequestOperationManager* requestOperationManager;

@end

#pragma mark -

@implementation CDAClient

// Terrible workaround to keep static builds from stripping these classes out.
+(void)load {
    NSArray* classes = @[ [CDAContentType class] ];
    classes = nil;
}

#pragma mark -

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
    return [self.requestOperationManager fetchArrayAtURLPath:URLPath
                                                  parameters:parameters
                                                     success:success
                                                     failure:failure];
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
    NSMutableDictionary* mutableQuery = [query mutableCopy];
    [query enumerateKeysAndObjectsUsingBlock:^(NSString* key, id value, BOOL *stop) {
        if ([value isKindOfClass:[NSArray class]]) {
            mutableQuery[key] = [value componentsJoinedByString:@","];
        }
        
        if ([value isKindOfClass:[NSDate class]]) {
            mutableQuery[key] = [self.dateFormatter stringFromDate:value];
        }
    }];
    query = [mutableQuery copy];
    
    if (self.contentTypeRegistry.fetched) {
        return [self fetchArrayAtURLPath:@"entries" parameters:query success:success failure:failure];
    } else {
        return [self fetchContentTypesWithSuccess:^(CDAResponse *response, CDAArray *array) {
            [self fetchArrayAtURLPath:@"entries" parameters:query success:success failure:failure];
        } failure:failure];
    }
}

-(CDARequest*)fetchEntriesWithSuccess:(CDAArrayFetchedBlock)success
                              failure:(CDARequestFailureBlock)failure {
    if (self.contentTypeRegistry.fetched) {
        return [self fetchArrayAtURLPath:@"entries" success:success failure:failure];
    } else {
        return [self fetchContentTypesWithSuccess:^(CDAResponse *response, CDAArray *array) {
            [self fetchArrayAtURLPath:@"entries" success:success failure:failure];
        } failure:failure];
    }
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
    return [self.requestOperationManager fetchSpaceWithSuccess:success failure:failure];
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
    self = [super init];
    if (self) {
        self.configuration = configuration;
        self.contentTypeRegistry = [CDAContentTypeRegistry new];
        self.dateFormatter = [ISO8601DateFormatter new];
        self.requestOperationManager = [[CDARequestOperationManager alloc] initWithSpaceKey:spaceKey accessToken:accessToken client:self configuration:configuration];
    }
    return self;
}

-(NSString *)protocol {
    return self.configuration.secure ? @"https" : @"http";
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
