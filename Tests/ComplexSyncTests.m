//
//  ComplexSyncTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 09/04/14.
//
//

#import "SyncBaseTestCase.h"

@interface ComplexSyncTests : SyncBaseTestCase

@end

#pragma mark -

@implementation ComplexSyncTests

-(void)setUp {
    [super setUp];
    
    /*
     Map URLs to JSON response files
     */
    NSDictionary* stubs = @{ @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?access_token=1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac&initial=true": @"LinkTestInitial", @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?access_token=1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac&sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyYZw7DCkTbDliYIw4vDp0jCqMOQw7vDqAbCoiLDkAnCs8OWXcOEwpXClGoUWMK1w54KCmlqw48Ow6EaJzQjwrnCnS3DpsKOw57CpMK1wrEGwrV8wpzCmcKtwqbCisK4w5LDgMKYw6HDsQ": @"LinkTestUpdate", @"https://cdn.contentful.com/spaces/emh6o2ireilu/?access_token=1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac": @"space", @"https://cdn.contentful.com/spaces/emh6o2ireilu/entries?access_token=1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac&sys.id%5Bin%5D=6nRlw4CofeeICEYgIqaIIg": @"LinkTestResolve", };
    
    [self stubHTTPRequestUsingFixtures:stubs inDirectory:@"ComplexSyncTests"];
}

-(void)testSyncWithLinks {
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
    
    XCTAssertEqual(2U, self.numberOfEntriesCreated, @"");
    XCTAssertEqual(0U, self.numberOfEntriesUpdated, @"");
}

-(void)testSyncWithLinksWithoutSyncSpaceInstance {
    StartBlock();
    
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response, CDASyncedSpace *space) {
        NSString* syncToken = space.syncToken;
        space = nil;
        XCTAssertNil(space, @"");
        
        self.client = [self mockContentTypeRetrievalForClient:[self buildClient]];
        CDASyncedSpace* shallowSyncSpace = [CDASyncedSpace shallowSyncSpaceWithToken:syncToken
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
    
    XCTAssertEqual(2U, self.numberOfEntriesCreated, @"");
    XCTAssertEqual(0U, self.numberOfEntriesUpdated, @"");
}

@end
