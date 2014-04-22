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
    NSDictionary* stubs = @{ @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?access_token=1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac&initial=true": @"AssetTestInitial", @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?access_token=1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac&sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyZ7T8Obw5Inwoh6Tk7Cq8KUDcK7w5ssw6vCgjLDjk9Hwr3DusOzw7XCo8OIwo3CicK5SBkqCcK7woDDhSjCkMOGw7rCqMOtE1V1L3LDq8KIck_DssK4K8OBe0vDn0vDrXjDkMOf": @"AssetTestUpdate", @"https://cdn.contentful.com/spaces/emh6o2ireilu/?access_token=1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac": @"space", @"https://cdn.contentful.com/spaces/emh6o2ireilu/assets?access_token=1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac&limit=1&sys.id%5Bin%5D=2q1Ns7Oygo2mAgoweuMCAA": @"AssetTestResolve", @"https://cdn.contentful.com/spaces/emh6o2ireilu/entries?access_token=1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac&limit=1&sys.id%5Bin%5D=6nRlw4CofeeICEYgIqaIIg": @"AssetTestResolve2",  };
    
    [self stubHTTPRequestUsingFixtures:stubs inDirectory:@"ComplexSyncTests"];
}

-(void)syncedSpace:(CDASyncedSpace *)space didCreateEntry:(CDAEntry *)entry {
    [super syncedSpace:space didCreateEntry:entry];
    
    XCTAssertNotNil([entry.fields[@"picture"] URL], @"");
}

-(void)testSyncLinkedAsset {
    StartBlock();
    
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response, CDASyncedSpace *space) {
        space.delegate = self;
        
        [space performSynchronizationWithSuccess:^{
            EndBlock();
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);
            
            EndBlock();
        }];
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    XCTAssertNotNil(request, @"");
    
    WaitUntilBlockCompletes();
}

-(void)testSyncLinkedAssetWithoutSyncSpaceInstance {
    StartBlock();
    
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response, CDASyncedSpace *space) {
        CDASyncedSpace* shallowSyncSpace = [CDASyncedSpace shallowSyncSpaceWithToken:space.syncToken
                                                                              client:self.client];
        shallowSyncSpace.delegate = self;
        
        [shallowSyncSpace performSynchronizationWithSuccess:^{
            EndBlock();
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);
            
            EndBlock();
        }];
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    XCTAssertNotNil(request, @"");
    
    WaitUntilBlockCompletes();
}

@end
