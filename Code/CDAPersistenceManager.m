//
//  CDAPersistenceManager.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 15/04/14.
//
//

#import <ContentfulDeliveryAPI/CDAEntry.h>
#import <ContentfulDeliveryAPI/CDASyncedSpace.h>

#import "CDAPersistenceManager.h"

@interface CDAPersistenceManager () <CDASyncedSpaceDelegate>

@property (nonatomic) CDAClient* client;
@property (nonatomic) CDASyncedSpace* syncedSpace;

@end

#pragma mark -

@implementation CDAPersistenceManager

-(id<CDAPersistedEntry>)createPersistedEntry {
    return [self.classForEntries new];
}

-(id<CDAPersistedSpace>)createPersistedSpace {
    return [self.classForSpaces new];
}

-(id<CDAPersistedSpace>)fetchSpaceFromDataStore {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
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

-(void)performSynchronizationWithSuccess:(void (^)())success
                                 failure:(CDARequestFailureBlock)failure {
    NSParameterAssert(self.classForEntries);
    NSParameterAssert(self.classForSpaces);
    NSParameterAssert(self.client);
    
    if (!self.syncedSpace) {
        [self.client initialSynchronizationWithSuccess:^(CDAResponse *response,
                                                         CDASyncedSpace *space) {
            [self persistedSpaceForSpace:space];
            
            for (CDAEntry* entry in space.entries) {
                [self persistedEntryForEntry:entry];
            }
            
            [self saveDataStore];
            
            if (success) {
                success();
            }
        } failure:failure];
        
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

-(id<CDAPersistedEntry>)persistedEntryForEntry:(CDAEntry*)entry {
    id<CDAPersistedEntry> persistedEntry = [entry mapFieldsToObject:[self createPersistedEntry]
                                                       usingMapping:self.mappingForEntries];
    persistedEntry.identifier = entry.identifier;
    return persistedEntry;
}

-(id<CDAPersistedSpace>)persistedSpaceForSpace:(CDASyncedSpace*)space {
    id<CDAPersistedSpace> persistedSpace = [self createPersistedSpace];
    persistedSpace.lastSyncTimestamp = space.lastSyncTimestamp;
    persistedSpace.syncToken = space.syncToken;
    return persistedSpace;
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
        _syncedSpace.lastSyncTimestamp = persistedSpace.lastSyncTimestamp;
    }
    
    return _syncedSpace;
}

#pragma mark - CDASyncedSpaceDelegate

-(void)syncedSpace:(CDASyncedSpace *)space didCreateAsset:(CDAAsset *)asset {
    // TODO: Implement.
}

-(void)syncedSpace:(CDASyncedSpace *)space didCreateEntry:(CDAEntry *)entry {
    // TODO: Implement.
}

-(void)syncedSpace:(CDASyncedSpace *)space didDeleteAsset:(CDAAsset *)asset {
    // TODO: Implement.
}

-(void)syncedSpace:(CDASyncedSpace *)space didDeleteEntry:(CDAEntry *)entry {
    // TODO: Implement.
}

-(void)syncedSpace:(CDASyncedSpace *)space didUpdateAsset:(CDAAsset *)asset {
    // TODO: Implement.
}

-(void)syncedSpace:(CDASyncedSpace *)space didUpdateEntry:(CDAEntry *)entry {
    // TODO: Implement.
}

@end
