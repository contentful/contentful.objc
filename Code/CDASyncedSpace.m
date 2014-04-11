//
//  CDASyncedSpace.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 25/03/14.
//
//

#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>

#import "CDAArray+Private.h"
#import "CDAClient+Private.h"
#import "CDAContentTypeRegistry.h"
#import "CDADeletedAsset.h"
#import "CDADeletedEntry.h"
#import "CDAEntry+Private.h"
#import "CDARequestOperationManager.h"
#import "CDAResource+Private.h"
#import "CDASyncedSpace+Private.h"
#import "CDAUtilities.h"

@interface CDASyncedSpace ()

@property (nonatomic) NSMutableArray* syncedAssets;
@property (nonatomic) NSMutableArray* syncedEntries;

@end

#pragma mark -

@implementation CDASyncedSpace

+(instancetype)readFromFile:(NSString*)filePath client:(CDAClient*)client {
    CDASyncedSpace* item = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        item = [[[self class] alloc] initWithCoder:unarchiver];
        [unarchiver finishDecoding];
    }
    
    item.client = client;
    return item;
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
    return [self.syncedAssets copy];
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    CDAEncodeObjectWithCoder(self, aCoder);
}

-(NSArray *)entries {
    return [self.syncedEntries copy];
}

-(void)handleSynchronizationResponseWithArray:(CDAArray*)array
                                      success:(void (^)())success
                                      failure:(CDARequestFailureBlock)failure {
    NSDate* nextTimestamp = self.lastSyncTimestamp;
    
    for (CDAResource* item in array.items) {
        if ([item updatedAfterDate:nextTimestamp]) {
            nextTimestamp = item.sys[@"updatedAt"];
        }
        
        if ([item isKindOfClass:[CDADeletedAsset class]]) {
            CDAAsset* deletedAsset = (CDAAsset*)item;
            
            for (CDAAsset* asset in self.syncedAssets) {
                if ([asset.identifier isEqualToString:item.identifier]) {
                    deletedAsset = asset;
                    break;
                }
            }
            
            if ([self.delegate respondsToSelector:@selector(syncedSpace:didDeleteAsset:)]) {
                [self.delegate syncedSpace:self didDeleteAsset:deletedAsset];
            }
            
            [self willChangeValueForKey:@"assets"];
            [self.syncedAssets removeObject:deletedAsset];
            [self didChangeValueForKey:@"assets"];
        }
        
        if ([item isKindOfClass:[CDADeletedEntry class]]) {
            CDAEntry* deletedEntry = (CDAEntry*)item;
            
            for (CDAEntry* entry in self.syncedEntries) {
                if ([entry.identifier isEqualToString:item.identifier]) {
                    deletedEntry = entry;
                    break;
                }
            }
            
            if ([self.delegate respondsToSelector:@selector(syncedSpace:didDeleteEntry:)]) {
                [self.delegate syncedSpace:self didDeleteEntry:deletedEntry];
            }
            
            [self willChangeValueForKey:@"entries"];
            [self.syncedEntries removeObject:deletedEntry];
            [self didChangeValueForKey:@"entries"];
        }
        
        if ([item isKindOfClass:[CDAAsset class]]) {
            [self willChangeValueForKey:@"assets"];
            
            NSUInteger assetIndex = [self.syncedAssets indexOfObject:item];
            if (!self.syncedAssets) {
                assetIndex = [item createdAfterDate:self.lastSyncTimestamp] ? NSNotFound : 0;
            }
            
            if (assetIndex != NSNotFound) {
                [self.syncedAssets replaceObjectAtIndex:assetIndex withObject:item];
                
                if ([self.delegate respondsToSelector:@selector(syncedSpace:didUpdateAsset:)]) {
                    [self.delegate syncedSpace:self didUpdateAsset:(CDAAsset*)item];
                }
            } else {
                [self.syncedAssets addObject:item];
                
                if ([self.delegate respondsToSelector:@selector(syncedSpace:didCreateAsset:)]) {
                    [self.delegate syncedSpace:self didCreateAsset:(CDAAsset*)item];
                }
            }
            
            [self didChangeValueForKey:@"assets"];
        }
        
        if ([item isKindOfClass:[CDAEntry class]]) {
            [self willChangeValueForKey:@"entries"];
            
            NSUInteger entryIndex = [self.syncedEntries indexOfObject:item];
            if (!self.syncedEntries) {
                entryIndex = [item createdAfterDate:self.lastSyncTimestamp] ? NSNotFound : 0;
            }
            
            if (entryIndex != NSNotFound) {
                [self.syncedEntries replaceObjectAtIndex:entryIndex withObject:item];
                
                if ([self.delegate respondsToSelector:@selector(syncedSpace:didUpdateEntry:)]) {
                    [self.delegate syncedSpace:self didUpdateEntry:(CDAEntry*)item];
                }
            } else {
                [self.syncedEntries addObject:item];
                
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
        self.syncedAssets = [@[] mutableCopy];
        self.syncedEntries = [@[] mutableCopy];
    }
    return self;
}

-(id)initWithAssets:(NSArray *)assets entries:(NSArray *)entries {
    self = [self init];
    if (self) {
        [self.syncedAssets addObjectsFromArray:assets];
        [self.syncedEntries addObjectsFromArray:entries];
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
    
    [self.client.requestOperationManager fetchArrayAtURLPath:@"sync" parameters:@{ @"sync_token": self.syncToken } success:^(CDAResponse *response, CDAArray *array) {
        if (!self.syncedAssets && !self.syncedEntries) {
            [self resolveLinksInArray:array
                              success:^{
                                  [self handleSynchronizationResponseWithArray:array
                                                                       success:success
                                                                       failure:failure];
                              } failure:failure];
        } else {
            [self handleSynchronizationResponseWithArray:array success:success failure:failure];
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
        if ([item isKindOfClass:[CDAEntry class]]) {
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
        [self.client fetchAssetsMatching:@{ @"sys.id[in]": unresolvedAssetIds }
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
    
    if (unresolvedEntryIds.count == 0) {
        [self resolveLinksInEntries:entries withIncludedAssets:assetsMap entries:@{}];
        
        success();
    } else {
        [self.client fetchEntriesMatching:@{ @"sys.id[in]": unresolvedEntryIds }
                                  success:^(CDAResponse *response, CDAArray *array) {
                                      NSMutableDictionary* entriesMap = [@{} mutableCopy];
                                      for (CDAEntry* entry in entries) {
                                          entriesMap[entry.identifier] = entry;
                                      }
                                      
                                      [self resolveLinksInEntries:entries
                                               withIncludedAssets:assetsMap
                                                          entries:entriesMap];
                                      
                                      success();
                                  } failure:failure];
    }
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
    for (NSString* parameters in [url.query componentsSeparatedByString:@"&"]) {
        NSArray* query = [parameters componentsSeparatedByString:@"="];
        
        if ([[query firstObject] isEqualToString:@"sync_token"]) {
            return [query lastObject];
        }
    }
    
    return nil;
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
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [self encodeWithCoder:archiver];
    [archiver finishEncoding];
    [data writeToFile:filePath atomically:YES];
}

@end
