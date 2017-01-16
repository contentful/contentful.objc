//
//  RealmQuerySyncTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 28/04/14.
//
//

#import "PersistenceBaseTest+QuerySync.h"
#import "RealmBaseTestCase.h"

@interface RealmQuerySyncTests : RealmBaseTestCase

@end

@implementation RealmQuerySyncTests

-(void)buildPersistenceManagerWithDefaultClient:(BOOL)defaultClient {
    [self querySync_setupClient];
    [super buildPersistenceManagerWithDefaultClient:NO];
}

#pragma mark -

-(void)testInitialSync {
    [self querySync_initial];
}

-(void)testAddEntry {
    [self querySync_addEntry];
}

-(void)testDeleteEntry {
    [self querySync_deleteEntry];
}

-(void)testUpdateAsset {
    [self querySync_updateAsset];
}

-(void)testUpdateEntry {
    [self querySync_updateEntry];
}

@end
