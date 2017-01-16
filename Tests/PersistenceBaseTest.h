//
//  PersistenceBaseTest.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 08/12/14.
//
//

#import "SyncBaseTestCase.h"

@interface PersistedObject

-(id<CDAPersistedAsset>)picture;

@end

#pragma mark -

@interface PersistenceBaseTest : SyncBaseTestCase

@property (nonatomic, readonly) CDAPersistenceManager* persistenceManager;
@property (nonatomic) NSDictionary* query;
@property (nonatomic) NSDate* lastSyncTimestamp;

-(void)assertNumberOfAssets:(NSUInteger)numberOfAssets numberOfEntries:(NSUInteger)numberOfEntries;
-(void)buildPersistenceManagerWithDefaultClient:(BOOL)defaultClient;
-(CDAPersistenceManager*)createPersistenceManagerWithClient:(CDAClient*)client;

-(void)deleteStore;

@end
