//
//  SyncSpecificContentTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 30/04/14.
//
//

#import "SyncBaseTestCase.h"

@interface SyncSpecificContentTests : SyncBaseTestCase

@end

#pragma mark -

@implementation SyncSpecificContentTests

-(void)performSyncTestWithQuery:(NSDictionary*)query
         expectedNumberOfAssets:(NSUInteger)numberOfAssets
                        entries:(NSUInteger)numberOfEntries {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [self.client initialSynchronizationMatching:query
                                        success:^(CDAResponse *response, CDASyncedSpace *space) {
                                            XCTAssertEqual(numberOfAssets, space.assets.count, @"");
                                            XCTAssertEqual(numberOfEntries, space.entries.count, @"");
                                            
                                            [expectation fulfill];
                                        } failure:^(CDAResponse *response, NSError *error) {
                                            XCTFail(@"Error: %@", error);
                                            
                                            [expectation fulfill];
                                        }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

#pragma mark -

-(void)testThrowsWhenSpecifyingInvalidQuery {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [self.client initialSynchronizationMatching:@{ @"type": @"bar" }
                                        success:^(CDAResponse *response, CDASyncedSpace *space) {
                                            XCTFail(@"This shouldn't be reached.");
                                            
                                            [expectation fulfill];
                                        } failure:^(CDAResponse *response, NSError *error) {
                                            XCTAssertNotNil(error, @"");
                                            
                                            [expectation fulfill];
                                        }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

-(void)testSyncAll {
    [self performSyncTestWithQuery:@{ @"type": @"all" }
            expectedNumberOfAssets:2U
                           entries:7U];
}

-(void)testSyncAssets {
    [self performSyncTestWithQuery:@{ @"type": @"Asset" }
            expectedNumberOfAssets:2U
                           entries:0U];
}

-(void)testSyncEntries {
    [self performSyncTestWithQuery:@{ @"type": @"Entry" }
            expectedNumberOfAssets:0U
                           entries:7U];
}

-(void)testSyncEntriesForContentType {
    self.client = [CDAClient new];
    
    [self performSyncTestWithQuery:@{ @"type": @"Entry", @"content_type": @"cat" }
            expectedNumberOfAssets:0U
                           entries:3U];
}

-(void)testSyncDeletions {
    [self performSyncTestWithQuery:@{ @"type": @"Deletion" }
            expectedNumberOfAssets:0U
                           entries:0U];
}

-(void)testSyncDeletionsOfAssets {
    [self performSyncTestWithQuery:@{ @"type": @"DeletedAsset" }
            expectedNumberOfAssets:0U
                           entries:0U];
}

-(void)testSyncDeletionsOfEntries {
    [self performSyncTestWithQuery:@{ @"type": @"DeletedEntry" }
            expectedNumberOfAssets:0U
                           entries:0U];
}

@end
