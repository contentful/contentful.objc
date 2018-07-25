//
//  AddContentTypesSyncTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 11/04/14.
//
//

#import "SyncBaseTestCase.h"
@import XCTest;

@interface AddContentTypesSyncTests : SyncBaseTestCase

@end

#pragma mark -

@implementation AddContentTypesSyncTests

-(void)setUp {
    [super setUp];
    
    /*
     Map URLs to JSON response files
     */
    NSDictionary* stubs = @{ @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?initial=true": @"AddContentTypesInitial", @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdybCr1IuSMKBHcKNbynCrcOdF8KoNCA_cwJHKx5VfW1EMsOBdkFww5_CjcOMQcOQw4_Dg8KjNcK8w7RrYCY8w57DmjM5wprDgcOxw7JOw7jDuQjDgsKVTsKBw7HDvcOX": @"AddContentTypesUpdate", @"https://cdn.contentful.com/spaces/emh6o2ireilu/": @"space", @"https://cdn.contentful.com/spaces/emh6o2ireilu/content_types?limit=1&sys.id%5Bin%5D=5kLp8FbRwAG0kcOOYa6GMa": @"AddContentTypesContentTypes", };
    
    [self stubHTTPRequestUsingFixtures:stubs inDirectory:@"ComplexSyncTests"];
}

-(void)testAddContentTypesDuringSyncSession {
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
    
    XCTAssertEqual(1U, self.numberOfEntriesCreated, @"");
}

@end
