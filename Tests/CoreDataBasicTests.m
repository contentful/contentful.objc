//
//  CoreDataBasicTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 15/04/14.
//
//

#import "CoreDataBaseTestCase.h"
#import "CoreDataManager.h"
#import "PersistenceBaseTest+Basic.h"

@interface CoreDataBasicTests : CoreDataBaseTestCase

@end

#pragma mark -

@implementation CoreDataBasicTests

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

-(void)testHasChanged {
    [self basic_hasChanged];
}

-(void)testInitialSync {
    [self basic_initialSync];
}

-(void)testMappingOfFields {
    [self removeAllStubs];
    [self buildPersistenceManagerWithDefaultClient:YES];
    
    StartBlock();
    
    [self.persistenceManager performSynchronizationWithSuccess:^{
        for (ManagedCat* cat in [(CoreDataManager*)self.persistenceManager fetchEntriesOfContentTypeWithIdentifier:@"cat" matchingPredicate:nil]) {
            XCTAssertNotNil(cat.color, @"");
            XCTAssertNotNil(cat.name, @"");
            XCTAssert([cat.livesLeft intValue] > 0, @"");
        }
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
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

-(void)testSyncEmptyField {
    [self basic_syncEmptyField];
}

@end
