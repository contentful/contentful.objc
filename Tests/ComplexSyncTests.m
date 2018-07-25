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
    NSDictionary* stubs = @{ @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?initial=true": @"LinkTestInitial", @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyYZw7DCkTbDliYIw4vDp0jCqMOQw7vDqAbCoiLDkAnCs8OWXcOEwpXClGoUWMK1w54KCmlqw48Ow6EaJzQjwrnCnS3DpsKOw57CpMK1wrEGwrV8wpzCmcKtwqbCisK4w5LDgMKYw6HDsQ": @"LinkTestUpdate", @"https://cdn.contentful.com/spaces/emh6o2ireilu/": @"space", @"https://cdn.contentful.com/spaces/emh6o2ireilu/entries?sys.id%5Bin%5D=6nRlw4CofeeICEYgIqaIIg": @"LinkTestResolve", };
    
    [self stubHTTPRequestUsingFixtures:stubs inDirectory:@"ComplexSyncTests"];
}

-(void)testSyncWithLinks {
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
    
    XCTAssertEqual(2U, self.numberOfEntriesCreated, @"");
    XCTAssertEqual(0U, self.numberOfEntriesUpdated, @"");
}

-(void)testSyncWithLinksWithoutSyncSpaceInstance {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response, CDASyncedSpace *space) {
        NSString* syncToken = space.syncToken;
        space = nil;
        XCTAssertNil(space, @"");
        
        self.client = [self mockContentTypeRetrievalForClient:[self buildClient]];
        CDASyncedSpace* shallowSyncSpace = [CDASyncedSpace shallowSyncSpaceWithToken:syncToken
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
    
    XCTAssertEqual(2U, self.numberOfEntriesCreated, @"");
    XCTAssertEqual(0U, self.numberOfEntriesUpdated, @"");
}

@end
