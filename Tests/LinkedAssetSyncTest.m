//
//  LinkedAssetSyncTest.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 09/04/14.
//
//

#import "SyncBaseTestCase.h"

@interface LinkedAssetSyncTest : SyncBaseTestCase

@end

#pragma mark -

@implementation LinkedAssetSyncTest

-(void)setUp {
    [super setUp];
    
    /*
     Map URLs to JSON response files
     */
    NSDictionary* stubs = @{ @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?initial=true": @"AssetTestInitial", @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyZ7T8Obw5Inwoh6Tk7Cq8KUDcK7w5ssw6vCgjLDjk9Hwr3DusOzw7XCo8OIwo3CicK5SBkqCcK7woDDhSjCkMOGw7rCqMOtE1V1L3LDq8KIck_DssK4K8OBe0vDn0vDrXjDkMOf": @"AssetTestUpdate", @"https://cdn.contentful.com/spaces/emh6o2ireilu/": @"space", @"https://cdn.contentful.com/spaces/emh6o2ireilu/assets?limit=1&sys.id%5Bin%5D=2q1Ns7Oygo2mAgoweuMCAA": @"AssetTestResolve", @"https://cdn.contentful.com/spaces/emh6o2ireilu/entries?limit=1&sys.id%5Bin%5D=6nRlw4CofeeICEYgIqaIIg": @"AssetTestResolve2",  };
    
    [self stubHTTPRequestUsingFixtures:stubs inDirectory:@"ComplexSyncTests"];
}

-(void)syncedSpace:(CDASyncedSpace *)space didCreateEntry:(CDAEntry *)entry {
    [super syncedSpace:space didCreateEntry:entry];
    
    XCTAssertNotNil([entry.fields[@"picture"] URL], @"");
}

-(void)testSyncLinkedAsset {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response, CDASyncedSpace *space) {
        space.delegate = self;
        
        [space performSynchronizationWithSuccess:^{
            [expectation fulfill];
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);
            
            [expectation fulfill];
        }];
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        [expectation fulfill];
    }];
    XCTAssertNotNil(request, @"");
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

-(void)testSyncLinkedAssetWithoutSyncSpaceInstance {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response, CDASyncedSpace *space) {
        CDASyncedSpace* shallowSyncSpace = [CDASyncedSpace shallowSyncSpaceWithToken:space.syncToken
                                                                              client:self.client];
        shallowSyncSpace.delegate = self;
        
        [shallowSyncSpace performSynchronizationWithSuccess:^{
            [expectation fulfill];
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);
            
            [expectation fulfill];
        }];
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        [expectation fulfill];
    }];
    XCTAssertNotNil(request, @"");
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

@end
