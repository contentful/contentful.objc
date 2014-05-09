//
//  CDAPersistenceManager.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 15/04/14.
//
//

#import <ContentfulDeliveryAPI/CDAArray.h>
#import <ContentfulDeliveryAPI/CDAAsset.h>
#import <ContentfulDeliveryAPI/CDASyncedSpace.h>

#import "CDAEntry+Private.h"
#import "CDAPersistenceManager.h"
#import "CDAUtilities.h"

@interface CDAPersistenceManager () <CDASyncedSpaceDelegate>

@property (nonatomic) CDAClient* client;
@property (nonatomic, copy) NSDictionary* query;
@property (nonatomic) CDASyncedSpace* syncedSpace;

@end

#pragma mark -

@implementation CDAPersistenceManager

+(void)seedFromBundleWithInitialCacheDirectory:(NSString*)initialCacheDirectory {
    NSString* cacheDirectory = CDACacheDirectory();
    
    if ([[NSFileManager defaultManager] contentsOfDirectoryAtPath:cacheDirectory error:nil].count > 0) {
        return;
    }
    
    NSArray* resources = [[NSBundle mainBundle] pathsForResourcesOfType:@"data"
                                                            inDirectory:initialCacheDirectory];
    
    for (NSString* resource in resources) {
        NSString* target = [cacheDirectory stringByAppendingPathComponent:resource.lastPathComponent];
        [[NSFileManager defaultManager] copyItemAtPath:resource toPath:target error:nil];
    }
}

#pragma mark -

-(id<CDAPersistedAsset>)createPersistedAsset {
    return [self.classForAssets new];
}

-(id<CDAPersistedEntry>)createPersistedEntry {
    return [self.classForEntries new];
}

-(id<CDAPersistedSpace>)createPersistedSpace {
    return [self.classForSpaces new];
}

-(void)deleteAssetWithIdentifier:(NSString*)identifier {
    [self doesNotRecognizeSelector:_cmd];
}

-(void)deleteEntryWithIdentifier:(NSString*)identifier {
    [self doesNotRecognizeSelector:_cmd];
}

-(NSArray *)fetchAssetsFromDataStore {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(id<CDAPersistedAsset>)fetchAssetWithIdentifier:(NSString*)identifier {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(id<CDAPersistedEntry>)fetchEntryWithIdentifier:(NSString*)identifier {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(id<CDAPersistedSpace>)fetchSpaceFromDataStore {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(void)handleAsset:(CDAAsset*)asset {
    id<CDAPersistedAsset> persistedAsset = [self fetchAssetWithIdentifier:asset.identifier];
    
    if (persistedAsset) {
        [self updatePersistedAsset:persistedAsset withAsset:asset];
    } else {
        [self persistedAssetForAsset:asset];
    }
}

-(void)handleEntry:(CDAEntry*)entry {
    id<CDAPersistedEntry> persistedEntry = [self fetchEntryWithIdentifier:entry.identifier];
    
    if (persistedEntry) {
        [self updatePersistedEntry:persistedEntry withEntry:entry];
    } else {
        [self persistedEntryForEntry:entry];
    }
}

-(void)handleResponseArray:(CDAArray*)array withSuccess:(void (^)())success {
    for (CDAEntry* entry in array.items) {
        [self handleEntry:entry];
        
        [entry resolveLinksWithIncludedAssets:nil
                                      entries:nil
                                   usingBlock:^CDAResource *(CDAResource *resource,
                                                             NSDictionary *assets,
                                                             NSDictionary *entries) {
                                       if ([resource isKindOfClass:[CDAAsset class]]) {
                                           [self handleAsset:(CDAAsset*)resource];
                                       }
                                       
                                       if ([resource isKindOfClass:[CDAEntry class]]) {
                                           [self handleEntry:(CDAEntry*)resource];
                                       }
                                       
                                       return resource;
                                   }];
    }
    
    [self saveDataStore];
    
    if (success) {
        success();
    }
}

-(id)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(id)initWithClient:(CDAClient*)client {
    self = [super init];
    if (self) {
        self.client = client;
        self.mappingForEntries = @{};
    }
    return self;
}

-(id)initWithClient:(CDAClient *)client query:(NSDictionary *)query {
    self = [super init];
    if (self) {
        self.client = client;
        self.mappingForEntries = @{};
        self.query = query;
    }
    return self;
}

-(void)performInitalSynchronizationForQueryWithSuccess:(void (^)())success
                                               failure:(CDARequestFailureBlock)failure {
    NSDate* syncTimestamp = [self roundedCurrentDate];
    
    [self.client fetchEntriesMatching:self.query success:^(CDAResponse *response, CDAArray *array) {
        id<CDAPersistedSpace> space = [self fetchSpaceFromDataStore];
        space.lastSyncTimestamp = syncTimestamp;
        
        [self handleResponseArray:array withSuccess:success];
    } failure:failure];
}

-(void)performSubsequentSynchronizationWithSuccess:(void (^)())success
                                           failure:(CDARequestFailureBlock)failure {
    NSDate* syncTimestamp = [self roundedCurrentDate];
    NSMutableDictionary* query = [self.query mutableCopy];
    
    id<CDAPersistedSpace> space = [self fetchSpaceFromDataStore];
    query[@"sys.updatedAt[gt]"] = space.lastSyncTimestamp;
    
    NSArray* knownAssetIds = [[self fetchAssetsFromDataStore] valueForKey:@"identifier"];
    NSDictionary* queryForAssets = @{ @"sys.id[in]": knownAssetIds,
                                      @"sys.updatedAt[gt]": space.lastSyncTimestamp };
    
    [self.client fetchEntriesMatching:query success:^(CDAResponse *response, CDAArray *entries) {
        space.lastSyncTimestamp = syncTimestamp;
        
        [self.client fetchAssetsMatching:queryForAssets
                                 success:^(CDAResponse *response, CDAArray *assets) {
                                     for (CDAAsset* asset in assets.items) {
                                         [self handleAsset:asset];
                                     }
                                     
                                     [self handleResponseArray:entries withSuccess:success];
                                 }
                                 failure:failure];
    } failure:failure];
}

-(void)performSynchronizationWithSuccess:(void (^)())success
                                 failure:(CDARequestFailureBlock)failure {
    NSParameterAssert(self.classForAssets);
    NSParameterAssert(self.classForEntries);
    NSParameterAssert(self.classForSpaces);
    NSParameterAssert(self.client);
    
    if (self.query) {
        if (self.syncedSpace) {
            [self.syncedSpace performSynchronizationWithSuccess:^{
                [self performSubsequentSynchronizationWithSuccess:success failure:failure];
            } failure:failure];
        } else {
            [self.client initialSynchronizationMatching:@{ @"type": @"Deletion" } success:^(CDAResponse *response, CDASyncedSpace *space) {
                [self persistedSpaceForSpace:space];
                [self performInitalSynchronizationForQueryWithSuccess:success failure:failure];
            } failure:failure];
        }
        
        return;
    }
    
    if (!self.syncedSpace) {
        CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response,
                                                                               CDASyncedSpace *space) {
            [self persistedSpaceForSpace:space];
            
            for (CDAAsset* asset in space.assets) {
                [self persistedAssetForAsset:asset];
            }
            
            for (CDAEntry* entry in space.entries) {
                [self persistedEntryForEntry:entry];
            }
            
            [self saveDataStore];
            
            if (success) {
                success();
            }
        } failure:failure];
        
        request = nil;
        return;
    }
    
    [self.syncedSpace performSynchronizationWithSuccess:^{
        id<CDAPersistedSpace> space = [self fetchSpaceFromDataStore];
        space.lastSyncTimestamp = self.syncedSpace.lastSyncTimestamp;
        space.syncToken = self.syncedSpace.syncToken;
        
        [self saveDataStore];
        
        if (success) {
            success();
        }
    } failure:failure];
}

-(id<CDAPersistedAsset>)persistedAssetForAsset:(CDAAsset*)asset {
    id<CDAPersistedAsset> persistedAsset = [self createPersistedAsset];
    [self updatePersistedAsset:persistedAsset withAsset:asset];
    return persistedAsset;
}

-(id<CDAPersistedEntry>)persistedEntryForEntry:(CDAEntry*)entry {
    id<CDAPersistedEntry> persistedEntry = [self createPersistedEntry];
    [self updatePersistedEntry:persistedEntry withEntry:entry];
    return persistedEntry;
}

-(id<CDAPersistedSpace>)persistedSpaceForSpace:(CDASyncedSpace*)space {
    id<CDAPersistedSpace> persistedSpace = [self createPersistedSpace];
    persistedSpace.lastSyncTimestamp = space.lastSyncTimestamp;
    persistedSpace.syncToken = space.syncToken;
    return persistedSpace;
}

-(NSDate*)roundedCurrentDate {
    NSTimeInterval time = round([[NSDate date] timeIntervalSinceReferenceDate] / 60.0) * 60.0;
    return [NSDate dateWithTimeIntervalSinceReferenceDate:time];
}

-(void)saveDataStore {
    [self doesNotRecognizeSelector:_cmd];
}

-(CDASyncedSpace *)syncedSpace {
    if (!_syncedSpace) {
        id<CDAPersistedSpace> persistedSpace = [self fetchSpaceFromDataStore];
        if (!persistedSpace) {
            return nil;
        }
        
        _syncedSpace = [CDASyncedSpace shallowSyncSpaceWithToken:persistedSpace.syncToken
                                                          client:self.client];
        _syncedSpace.delegate = self;
        _syncedSpace.lastSyncTimestamp = persistedSpace.lastSyncTimestamp;
    }
    
    return _syncedSpace;
}

-(void)updatePersistedAsset:(id<CDAPersistedAsset>)persistedAsset withAsset:(CDAAsset*)asset {
    persistedAsset.identifier = asset.identifier;
    persistedAsset.mimeType = asset.MIMEType;
    persistedAsset.url = asset.URL.absoluteString;
}

-(void)updatePersistedEntry:(id<CDAPersistedEntry>)persistedEntry withEntry:(CDAEntry*)entry {
    [entry mapFieldsToObject:persistedEntry usingMapping:self.mappingForEntries];
    persistedEntry.identifier = entry.identifier;
}

#pragma mark - CDASyncedSpaceDelegate

-(void)syncedSpace:(CDASyncedSpace *)space didCreateAsset:(CDAAsset *)asset {
    [self persistedAssetForAsset:asset];
}

-(void)syncedSpace:(CDASyncedSpace *)space didCreateEntry:(CDAEntry *)entry {
    [self persistedEntryForEntry:entry];
}

-(void)syncedSpace:(CDASyncedSpace *)space didDeleteAsset:(CDAAsset *)asset {
    [self deleteAssetWithIdentifier:asset.identifier];
}

-(void)syncedSpace:(CDASyncedSpace *)space didDeleteEntry:(CDAEntry *)entry {
    [self deleteEntryWithIdentifier:entry.identifier];
}

-(void)syncedSpace:(CDASyncedSpace *)space didUpdateAsset:(CDAAsset *)asset {
    id<CDAPersistedAsset> persistedAsset = [self fetchAssetWithIdentifier:asset.identifier];
    [self updatePersistedAsset:persistedAsset withAsset:asset];
}

-(void)syncedSpace:(CDASyncedSpace *)space didUpdateEntry:(CDAEntry *)entry {
    id<CDAPersistedEntry> persistedEntry = [self fetchEntryWithIdentifier:entry.identifier];
    [self updatePersistedEntry:persistedEntry withEntry:entry];
}

@end
