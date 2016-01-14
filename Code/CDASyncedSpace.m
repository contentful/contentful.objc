//
//  CDASyncedSpace.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 25/03/14.
//
//

#import <ContentfulDeliveryAPI/CDADeletedAsset.h>
#import <ContentfulDeliveryAPI/CDADeletedEntry.h>
#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>

#import "CDAArray+Private.h"
#import "CDAClient+Private.h"
#import "CDAContentTypeRegistry.h"
#import "CDAEntry+Private.h"
#import "CDAResource+Private.h"
#import "CDASyncedSpace+Private.h"
#import "CDAUtilities.h"

@interface CDASyncedSpace ()

@property (nonatomic) NSMutableDictionary* syncedAssets;
@property (nonatomic) NSMutableDictionary* syncedEntries;

@end

#pragma mark -

@implementation CDASyncedSpace

+(nullable instancetype)readFromFile:(NSString*)filePath client:(CDAClient*)client {
    if (filePath == nil) {
        return nil;
    }
    return [self readFromFileURL:[NSURL fileURLWithPath:filePath] client:client];
}

+(nullable instancetype)readFromFileURL:(NSURL*)fileURL client:(CDAClient*)client {
    return CDAReadItemFromFileURL(fileURL, client);
}

+(instancetype)shallowSyncSpaceWithToken:(NSString *)syncToken client:(CDAClient *)client {
    CDASyncedSpace* space = [[self class] new];
    space.client = client;
    space.nextSyncUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://example.com/foo?sync_token=%@", syncToken]];
    space.syncedAssets = nil;
    space.syncedEntries = nil;
    return space;
}

+(BOOL)supportsSecureCoding {
    return YES;
}

#pragma mark -

-(NSArray *)assets {
    return self.syncedAssets.allValues;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    CDAEncodeObjectWithCoder(self, aCoder);
}

-(NSArray *)entries {
    return self.syncedEntries.allValues;
}

-(void)handleSynchronizationResponseWithArray:(CDAArray*)array
                                      success:(void (^)())success
                                      failure:(CDARequestFailureBlock)failure {
    NSMutableDictionary* newAssets = [@{} mutableCopy];
    NSMutableDictionary* newEntries = [@{} mutableCopy];
    NSDate* nextTimestamp = self.lastSyncTimestamp;
    
    for (CDAResource* item in array.items) {
        if (CDAClassIsOfType([item class], CDAAsset.class)) {
            newAssets[item.identifier] = item;
        }
        
        if (CDAClassIsOfType([item class], CDAEntry.class)) {
            newEntries[item.identifier] = item;
        }
    }
    
    for (CDAResource* item in array.items) {
        if ([item updatedAfterDate:nextTimestamp]) {
            nextTimestamp = item.sys[@"updatedAt"];
        }
        
        if ([CDADeletedAsset classIsOfType:item.class]) {
            CDAAsset* deletedAsset = self.syncedAssets[item.identifier] ?: (CDAAsset*)item;
            
            if ([self.delegate respondsToSelector:@selector(syncedSpace:didDeleteAsset:)]) {
                [self.delegate syncedSpace:self didDeleteAsset:deletedAsset];
            }
            
            [self willChangeValueForKey:@"assets"];
            [self.syncedAssets removeObjectForKey:deletedAsset.identifier];
            [self didChangeValueForKey:@"assets"];
        }
        
        if ([CDADeletedEntry classIsOfType:item.class]) {
            CDAEntry* deletedEntry = self.syncedEntries[item.identifier] ?: (CDAEntry*)item;
            
            if ([self.delegate respondsToSelector:@selector(syncedSpace:didDeleteEntry:)]) {
                [self.delegate syncedSpace:self didDeleteEntry:deletedEntry];
            }
            
            [self willChangeValueForKey:@"entries"];
            [self.syncedEntries removeObjectForKey:deletedEntry.identifier];
            [self didChangeValueForKey:@"entries"];
        }
        
        if ([CDAAsset classIsOfType:item.class]) {
            [self willChangeValueForKey:@"assets"];
            
            NSUInteger assetIndex = [self.syncedAssets.allKeys indexOfObject:item.identifier];
            if (!self.syncedAssets) {
                assetIndex = [item createdAfterDate:self.lastSyncTimestamp] ? NSNotFound : 0;
            }
            
            if (assetIndex != NSNotFound) {
                self.syncedAssets[item.identifier] = item;
                
                if ([self.delegate respondsToSelector:@selector(syncedSpace:didUpdateAsset:)]) {
                    [self.delegate syncedSpace:self didUpdateAsset:(CDAAsset*)item];
                }
            } else {
                self.syncedAssets[item.identifier] = item;
                
                if ([self.delegate respondsToSelector:@selector(syncedSpace:didCreateAsset:)]) {
                    [self.delegate syncedSpace:self didCreateAsset:(CDAAsset*)item];
                }
            }
            
            [self didChangeValueForKey:@"assets"];
        }
        
        if ([CDAEntry classIsOfType:item.class]) {
            [item resolveLinksWithIncludedAssets:self.syncedAssets entries:self.syncedEntries];
            [item resolveLinksWithIncludedAssets:newAssets entries:newEntries];
            
            [self willChangeValueForKey:@"entries"];
            
            NSUInteger entryIndex = [self.syncedEntries.allKeys indexOfObject:item.identifier];
            if (!self.syncedEntries) {
                entryIndex = [item createdAfterDate:self.lastSyncTimestamp] ? NSNotFound : 0;
            }
            
            if (entryIndex != NSNotFound) {
                self.syncedEntries[item.identifier] = item;
                
                if ([self.delegate respondsToSelector:@selector(syncedSpace:didUpdateEntry:)]) {
                    [self.delegate syncedSpace:self didUpdateEntry:(CDAEntry*)item];
                }
            } else {
                self.syncedEntries[item.identifier] = item;
                
                if ([self.delegate respondsToSelector:@selector(syncedSpace:didCreateEntry:)]) {
                    [self.delegate syncedSpace:self didCreateEntry:(CDAEntry*)item];
                }
            }
            
            [self didChangeValueForKey:@"entries"];
        }
    }
    
    self.lastSyncTimestamp = nextTimestamp;
    self.nextPageUrl = array.nextPageUrl;
    self.nextSyncUrl = array.nextSyncUrl;
    
    if (success) {
        if (self.nextPageUrl) {
            [self performSynchronizationWithSuccess:success failure:failure];
        } else {
            success();
        }
    }
}

-(id)init {
    self = [super init];
    if (self) {
        self.lastSyncTimestamp = [NSDate distantPast];
        self.syncedAssets = [@{} mutableCopy];
        self.syncedEntries = [@{} mutableCopy];
    }
    return self;
}

-(id)initWithAssets:(NSArray *)assets entries:(NSArray *)entries {
    self = [self init];
    if (self) {
        for (CDAAsset* asset in assets) {
            self.syncedAssets[asset.identifier] = asset;
        }
        
        for (CDAEntry* entry in entries) {
            self.syncedEntries[entry.identifier] = entry;
        }
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        CDADecodeObjectWithCoder(self, aDecoder);
    }
    return self;
}

-(void)performSynchronizationWithSuccess:(void (^)())success
                                 failure:(CDARequestFailureBlock)failure {
    NSParameterAssert(self.client);
    
    if (!self.syncToken) {
        if (failure) {
            failure(nil, [NSError errorWithDomain:CDAErrorDomain code:901 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"No sync token available.", nil) }]);
        }
        
        return;
    }

    [self.client fetchArrayAtURLPath:@"sync" parameters:@{ @"sync_token": self.syncToken ?: @"" } success:^(CDAResponse *response, CDAArray *array) {
        if (!self.syncedAssets && !self.syncedEntries) {
            [self resolveLinksInArray:array
                              success:^{
                                  [self handleSynchronizationResponseWithArray:array
                                                                       success:success
                                                                       failure:failure];
                              } failure:failure];
        } else {
            [self handleSynchronizationResponseWithArray:array success:^{
                for (CDAEntry* entry in self.syncedEntries.allValues) {
                    [entry resolveLinksWithIncludedAssets:self.syncedAssets entries:self.syncedEntries];
                }

                success();
            } failure:failure];
        }
    } failure:failure];
}

-(void)resolveLinksInArray:(CDAArray*)array
                   success:(void (^)())success
                   failure:(CDARequestFailureBlock)failure {
    NSMutableArray* entriesInQuery = [@[] mutableCopy];
    NSMutableArray* unresolvedAssets = [@[] mutableCopy];
    NSMutableArray* unresolvedEntries = [@[] mutableCopy];
    
    for (CDAResource* item in array.items) {
        if (CDAClassIsOfType([item class], CDAEntry.class)) {
            CDAEntry* entry = (CDAEntry*)item;
            [entriesInQuery addObject:item];
            [unresolvedAssets addObjectsFromArray:[entry findUnresolvedAssets]];
            [unresolvedEntries addObjectsFromArray:[entry findUnresolvedEntries]];
        }
    }
    
    if (entriesInQuery.count == 0) {
        success();
        return;
    }
    
    NSArray* unresolvedAssetIds = [unresolvedAssets valueForKey:@"identifier"];
    NSArray* unresolvedEntryIds = [unresolvedEntries valueForKey:@"identifier"];
    
    if (unresolvedAssetIds.count > 0) {
        [self.client fetchAssetsMatching:@{ @"sys.id[in]": unresolvedAssetIds,
                                            @"limit": @(unresolvedAssetIds.count) }
                                 success:^(CDAResponse *response, CDAArray *array) {
                                     [self resolveLinksInEntries:entriesInQuery
                                                     usingAssets:array.items
                                              unresolvedEntryIds:unresolvedEntryIds
                                                         success:success
                                                         failure:failure];
                                 } failure:failure];
    } else {
        [self resolveLinksInEntries:entriesInQuery
                        usingAssets:@[]
                 unresolvedEntryIds:unresolvedEntryIds
                            success:success
                            failure:failure];
    }
}

-(void)resolveLinksInEntries:(NSArray*)entries
                 usingAssets:(NSArray*)assets
            unresolvedEntryIds:(NSArray*)unresolvedEntryIds
                       success:(void (^)())success
                       failure:(CDARequestFailureBlock)failure  {
    if (assets.count == 0 && unresolvedEntryIds.count == 0) {
        success();
        return;
    }
    
    NSMutableDictionary* assetsMap = [@{} mutableCopy];
    for (CDAAsset* asset in assets) {
        assetsMap[asset.identifier] = asset;
    }

    [self resolveLinksInEntries:entries withIncludedAssets:assetsMap entries:@{}];

    success();
}

-(void)resolveLinksInEntries:(NSArray*)entriesWithLinks
          withIncludedAssets:(NSDictionary*)assets
                     entries:(NSDictionary*)entries {
    for (CDAEntry* entry in entriesWithLinks) {
        [entry resolveLinksWithIncludedAssets:assets entries:entries];
    }
}

-(NSString *)syncToken {
    return [self syncTokenFromURL:self.nextPageUrl] ?: [self syncTokenFromURL:self.nextSyncUrl] ?: nil;
}

-(NSString*)syncTokenFromURL:(NSURL*)url {
    return CDAValueForQueryParameter(url, @"sync_token");
}

-(void)updateLastSyncTimestamp {
    for (CDAAsset* asset in self.assets) {
        if ([asset updatedAfterDate:self.lastSyncTimestamp]) {
            self.lastSyncTimestamp = asset.sys[@"updatedAt"];
        }
    }
    
    for (CDAEntry* entry in self.entries) {
        if ([entry updatedAfterDate:self.lastSyncTimestamp]) {
            self.lastSyncTimestamp = entry.sys[@"updatedAt"];
        }
    }
}

-(void)writeToFile:(NSString*)filePath {
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self];
    [data writeToFile:filePath atomically:YES];
}

@end
