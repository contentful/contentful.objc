//
//  NewEntryAndDeletionSyncTest.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 10/04/14.
//
//

#import "SyncBaseTestCase.h"

@interface NewEntryAndDeletionSyncTest : SyncBaseTestCase

@end

#pragma mark -

@implementation NewEntryAndDeletionSyncTest

-(void)setUp {
    [super setUp];
    
    /*
     Map URLs to JSON response files
     */
    NSDictionary* stubs = @{ @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?access_token=1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac&initial=true": @"NewEntryAndDeletionInitial", @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?access_token=1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac&sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdybDjMOhw7gcw7BNwqzCqSDDhhrCjcKqWEDCjMKHwp4RE2ROw73ChnJnc3MVwpTCgcOcEMOxw53CpgbCpSXCocKbCBVHF8Kyw5nDmUIKwrnDpVByw4l5w57DvV4swoTCuxPCnQ": @"NewEntryAndDeletionUpdate", @"https://cdn.contentful.com/spaces/emh6o2ireilu/?access_token=1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac": @"space", @"https://cdn.contentful.com/spaces/emh6o2ireilu/assets?access_token=1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac&limit=1&sys.id%5Bin%5D=2q1Ns7Oygo2mAgoweuMCAA": @"NewEntryAndDeletionResolve", @"https://cdn.contentful.com/spaces/emh6o2ireilu/entries?access_token=1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac&limit=1&sys.id%5Bin%5D=6nRlw4CofeeICEYgIqaIIg": @"NewEntryAndDeletionResolve2", };
    
    [self stubHTTPRequestUsingFixtures:stubs inDirectory:@"ComplexSyncTests"];
}

-(void)testSyncNewEntryAndDeletion {
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
    
    XCTAssertEqual(1U, self.numberOfEntriesCreated, @"");
    XCTAssertEqual(1U, self.numberOfEntriesUpdated, @"");
}

-(void)testSyncNewEntryAndDeletionWithoutSyncSpaceInstance {
    StartBlock();
    
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response, CDASyncedSpace *space) {
        CDASyncedSpace* shallowSyncSpace = [CDASyncedSpace shallowSyncSpaceWithToken:space.syncToken
                                                                              client:self.client];
        shallowSyncSpace.delegate = self;
        shallowSyncSpace.lastSyncTimestamp = space.lastSyncTimestamp;
        
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
    
    XCTAssertEqual(1U, self.numberOfEntriesCreated, @"");
    XCTAssertEqual(1U, self.numberOfEntriesUpdated, @"");
}

@end
