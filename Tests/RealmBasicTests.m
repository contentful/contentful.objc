//
//  RealmBasicTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 15/04/14.
//
//

#import "PersistenceBaseTest+Basic.h"
#import "RealmBaseTestCase.h"

@interface RealmBasicTests : RealmBaseTestCase

@end

#pragma mark -

@implementation RealmBasicTests

-(void)setUp {
    [super setUp];
    
    [self basic_setupFixtures];
}

#pragma mark -

-(void)testContinueSyncFromDataStore {
    [self basic_continueSyncFromDataStore];
}

-(void)testContinueSyncWithSameManager {
    [self basic_continueSyncWithSameManager];
}

-(void)testInitialSync {
    [self basic_initialSync];
}

-(void)testRelationships {
    [self basic_relationships];
}

-(void)testSyncWithRepublishedEntry {
    [self basic_syncWithRepublishedEntries];
}

-(void)testImageCaching {
    [self basic_imageCaching];
}

@end
