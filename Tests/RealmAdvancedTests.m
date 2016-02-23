//
//  RealmAdvancedTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 22/02/16.
//
//

#import "PersistenceBaseTest+Basic.h"
#import "RealmBaseTestCase.h"
#import "RealmClassHierarchy.h"

@interface RealmAdvancedTests : RealmBaseTestCase

@end

#pragma mark -

@implementation RealmAdvancedTests

-(void)buildPersistenceManagerWithDefaultClient:(BOOL)defaultClient {
    [super buildPersistenceManagerWithDefaultClient:defaultClient];

    NSArray* contentTypeIds = @[ @"1nGOrvlRTaMcyyq4IEa8ea", @"6bAvxqodl6s4MoKuWYkmqe",
                                 @"6PnRGY1dxSUmaQ2Yq2Ege2", @"cat" ];
    NSDictionary* mapping = @{ @"fields.name": @"name", @"fields.bestFriend": @"bestFriend" };

    Class c = [RealmClassHierarchy class];
    for (NSString* contentTypeId in contentTypeIds) {
        [self.persistenceManager setClass:c forEntriesOfContentTypeWithIdentifier:contentTypeId];
        [self.persistenceManager setMapping:mapping forEntriesOfContentTypeWithIdentifier:contentTypeId];
    }
}

#pragma mark -

-(void)setUp {
    [super setUp];

    [self basic_setupFixtures];
}

#pragma mark -

-(void)testSyncWithClassHierarchy {
    [self removeAllStubs];
    [self buildPersistenceManagerWithDefaultClient:YES];

    StartBlock();

    [self.persistenceManager performSynchronizationWithSuccess:^{
        XCTAssertEqual(4U, [self.persistenceManager fetchAssetsFromDataStore].count, @"");
        XCTAssertEqual(3U, [self.persistenceManager fetchEntriesFromDataStore].count, @"");

        RealmClassHierarchy* nyancat = [self.persistenceManager fetchEntryWithIdentifier:@"nyancat"];
        XCTAssertNotNil(nyancat);
        RealmClassHierarchy* friend = nyancat.bestFriend;
        XCTAssertNotNil(friend);
        XCTAssertEqualObjects(friend.identifier, @"happycat");

        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);

        EndBlock();
    }];

    WaitUntilBlockCompletes();
}

@end
