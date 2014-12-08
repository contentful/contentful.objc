//
//  PersistenceBaseTest.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 08/12/14.
//
//

#import "Asset.h"
#import "ManagedCat.h"
#import "SyncBaseTestCase.h"

@interface PersistenceBaseTest : SyncBaseTestCase

@property (nonatomic, readonly) CDAPersistenceManager* persistenceManager;
@property (nonatomic) NSDictionary* query;

-(void)assertNumberOfAssets:(NSUInteger)numberOfAssets numberOfEntries:(NSUInteger)numberOfEntries;
-(void)buildPersistenceManagerWithDefaultClient:(BOOL)defaultClient;
-(CDAPersistenceManager*)createPersistenceManagerWithClient:(CDAClient*)client;

@end
