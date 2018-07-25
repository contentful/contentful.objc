//
//  APICoverageTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 19/01/16.
//
//

#import "ContentfulBaseTestCase.h"

typedef void(^CDAEntriesFetchBlock)(NSArray* entries);

@interface APICoverageTests : ContentfulBaseTestCase

@end

#pragma mark -

@implementation APICoverageTests

-(void)testFetchSingleAsset {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];

    [self.client fetchAssetWithIdentifier:@"nyancat" success:^(CDAResponse* response,
                                                               CDAAsset* asset) {
        XCTAssertEqualObjects(asset.identifier, @"nyancat");

        [expectation fulfill];
    } failure:^(CDAResponse* response, NSError* error) {
        XCTFail(@"%@", error);

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

-(void)testFetchSingleContentType {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];

    [self.client fetchContentTypeWithIdentifier:@"cat" success:^(CDAResponse* response,
                                                                 CDAContentType* contentType) {
        XCTAssertEqualObjects(contentType.identifier, @"cat");

        [expectation fulfill];
    } failure:^(CDAResponse* response, NSError* error) {
        XCTFail(@"%@", error);

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

-(void)testFetchSingleEntry {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];

    [self.client fetchEntryWithIdentifier:@"nyancat" success:^(CDAResponse* response,
                                                               CDAEntry* entry) {
        XCTAssertEqualObjects(entry.identifier, @"nyancat");

        [expectation fulfill];
    } failure:^(CDAResponse* response, NSError* error) {
        XCTFail(@"%@", error);

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

#pragma mark -

-(void)fetchEntriesMatching:(NSDictionary*)matching success:(CDAEntriesFetchBlock)success {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];

    [self.client fetchEntriesMatching:matching
                              success:^(CDAResponse* response, CDAArray* array) {
                                  success(array.items);

                                  [expectation fulfill];
                              } failure:^(CDAResponse* response, NSError* error) {
                                  XCTFail(@"%@", error);
                                  
                                  [expectation fulfill];
                              }];

    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

-(void)testFetchEntriesByAttributeExistsQuery {
    [self fetchEntriesMatching:@{ @"sys.archivedVersion[exists]": @NO } success:^(NSArray *entries) {
        XCTAssertEqual(entries.count, 10);
    }];
}

-(void)testFetchEntriesByLocationProximitySearch {
    [self fetchEntriesMatching:@{ @"fields.center[near]": @[@38, @-122], @"content_type": @"1t9IbcfdCk6m04uISSsaIK" } success:^(NSArray *entries) {
        XCTAssertEqual(entries.count, 4);
    }];
}

-(void)testFetchEntriesByLocationsInBoundingObject {
    [self fetchEntriesMatching:@{ @"fields.center[within]": @[@36, @-124, @40, @-120], @"content_type": @"1t9IbcfdCk6m04uISSsaIK" } success:^(NSArray *entries) {
        XCTAssertEqual(entries.count, 1);
    }];
}

-(void)testFetchEntriesWithIncludes {
    [self fetchEntriesMatching:@{ @"include": @3 } success:^(NSArray *entries) {
        XCTAssertEqual(entries.count, 10);
    }];
}

-(void)testFilterEntriesByLinkedEntries {
    [self fetchEntriesMatching:@{ @"content_type": @"cat", @"fields.bestFriend.sys.id": @"nyancat" } success:^(NSArray *entries) {
        XCTAssertEqual(entries.count, 1);
        XCTAssertEqualObjects([entries.firstObject identifier], @"happycat");
    }];
}

-(void)testOrderEntriesByTwoAttributes {
    [self fetchEntriesMatching:@{ @"order": @[@"sys.revision", @"sys.id"] } success:^(NSArray *entries) {
        NSArray* orderedEntriesByMultiple = @[ @"4MU1s3potiUEM2G4okYOqw",
                                               @"ge1xHyH3QOWucKWCCAgIG", @"6KntaYXaHSyIw8M6eo26OK",
                                               @"7qVBlCjpWE86Oseo40gAEY", @"garfield",
                                               @"5ETMRzkl9KM4omyMwKAOki", @"jake", @"nyancat", @"finn",
                                               @"happycat" ];

        NSArray* actualIds = [entries valueForKey:@"identifier"];

        XCTAssertEqualObjects(actualIds, orderedEntriesByMultiple);
    }];
}

#pragma mark -

-(void)testFetchAssetsByMimetypeGroup {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];

    [self.client fetchAssetsMatching:@{ @"mimetype_group": @"image" } success:^(CDAResponse* response,
                                                                                CDAArray* array) {
        XCTAssertEqual(array.items.count, 4);

        [expectation fulfill];
    } failure:^(CDAResponse* response, NSError* error) {
        XCTFail(@"%@", error);

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

/*
API endpoints not being tested:

/spaces/{space_id}/content_types/{content_type_id}
/spaces/{space_id}/entries/{entry_id}
/spaces/{space_id}/assets/{asset_id}

/spaces/{space_id}/entries/{entry_id}?locale={locale}
*/

@end
