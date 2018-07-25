//
//  SearchAPITests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 05/03/14.
//
//

#import <ISO8601/ISO8601.h>

#import "ContentfulBaseTestCase.h"

@interface SearchAPITests : ContentfulBaseTestCase

@end

#pragma mark -

@implementation SearchAPITests

- (void)testContentTypeSearch {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [self.client fetchEntriesMatching:@{ @"content_type": @"cat" }
        success:^(CDAResponse *response, CDAArray *array) {
            XCTAssertEqual(3U, array.items.count, @"");
            for (CDAEntry* entry in array.items) {
                if ([entry.identifier isEqualToString:@"garfield"]) {
                    XCTAssertEqualObjects(@"orange", entry.fields[@"color"], @"");
                    XCTAssertEqualObjects(@"Garfield", entry.fields[@"name"], @"");
                }
            }
            
            [expectation fulfill];
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);
            
            [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testEqualitySearch {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [self.client fetchEntriesMatching:@{ @"sys.id": @"nyancat" }
        success:^(CDAResponse *response, CDAArray *array) {
            XCTAssertEqual(1U, array.items.count, @"");
            XCTAssertEqualObjects(@"Nyan Cat", [[array.items firstObject] fields][@"name"], @"");
            
            [expectation fulfill];
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);
            
            [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testInequalitySearch {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [self.client fetchEntriesMatching:@{ @"sys.id[ne]": @"nyancat" }
        success:^(CDAResponse *response, CDAArray *array) {
            XCTAssertEqual(9U, array.items.count, @"");
            for (CDAEntry* entry in array.items) {
                XCTAssertNotEqualObjects(@"Nyan Cat", entry.fields[@"name"], @"");
            }
            
            [expectation fulfill];
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);
            
            [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testArrayEqualitySearch {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [self.client fetchEntriesMatching:@{ @"content_type": @"cat",
                                         @"fields.likes": @"lasagna" }
        success:^(CDAResponse *response, CDAArray *array) {
            XCTAssertEqual(1U, array.items.count, @"");
            XCTAssertEqualObjects(@"garfield", [[array.items firstObject] identifier], @"");
                                  
            [expectation fulfill];
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);
                                  
            [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testInclusionSearch {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [self.client fetchEntriesMatching:@{ @"sys.id[in]": @[ @"finn", @"jake" ] }
        success:^(CDAResponse *response, CDAArray *array) {
            XCTAssertEqual(2U, array.items.count, @"");
            for (CDAEntry* entry in array.items) {
                XCTAssert([entry.identifier isEqualToString:@"finn"] || [entry.identifier isEqualToString:@"jake"], @"");
            }
            
            [expectation fulfill];
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);
            
            [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testCompoundSearch {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [self.client fetchEntriesMatching:@{ @"content_type": @"cat",
                                         @"fields.likes[nin]": @[ @"rainbows", @"lasagna" ] }
        success:^(CDAResponse *response, CDAArray *array) {
            XCTAssertEqual(1U, array.items.count, @"");
            CDAEntry* entry = [array.items firstObject];
            XCTAssertEqualObjects(@"Happy Cat", entry.fields[@"name"], @"");
            XCTAssertEqualObjects(@[ @"cheezburger" ], entry.fields[@"likes"], @"");
            XCTAssertEqualObjects(@(1), entry.fields[@"lives"], @"");
            XCTAssertEqualObjects([NSURL URLWithString:@"https://images.contentful.com/cfexampleapi/3MZPnjZTIskAIIkuuosCss/382a48dfa2cb16c47aa2c72f7b23bf09/happycatw.jpg"],
                                  [((CDAAsset*)entry.fields[@"image"]) URL], @"");
            
            [expectation fulfill];
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);
            
            [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testNumberRangeSearch {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [self.client fetchEntriesMatching:@{ @"content_type": @"cat",
                                         @"fields.lives[lte]": @(3) }
        success:^(CDAResponse *response, CDAArray *array) {
            XCTAssertEqual(1U, array.items.count, @"");
            XCTAssertEqualObjects(@"happycat", [[array.items firstObject] identifier], @"");
            
            [expectation fulfill];
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);
            
            [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testDateRangeSearch {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    NSDate* date = [NSDate dateWithISO8601String:@"2013-01-01T00:00:00Z"];
    
    [self.client fetchEntriesMatching:@{ @"sys.updatedAt[gte]": date }
        success:^(CDAResponse *response, CDAArray *array) {
            XCTAssertEqual(10U, array.items.count, @"");
            
            [expectation fulfill];
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);
            
            [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testFullTextSearch {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [self.client fetchEntriesMatching:@{ @"query": @"bacon" }
        success:^(CDAResponse *response, CDAArray *array) {
            XCTAssertEqual(1U, array.items.count, @"");
            XCTAssertEqualObjects(@"jake", [[array.items firstObject] identifier], @"");
            XCTAssertEqualObjects(@"Bacon pancakes, makin' bacon pancakes!",
                                  [[array.items firstObject] fields][@"description"], @"");
            
            [expectation fulfill];
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);
            
            [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testFullTextSearchOnSpecificFields {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [self.client fetchEntriesMatching:@{ @"content_type": @"dog",
                                         @"fields.description[match]": @"bacon pancakes" }
        success:^(CDAResponse *response, CDAArray *array) {
            XCTAssertEqual(1U, array.items.count, @"");
            XCTAssertEqualObjects(@"jake", [[array.items firstObject] identifier], @"");
            XCTAssertEqualObjects(@"Bacon pancakes, makin' bacon pancakes!",
                                  [[array.items firstObject] fields][@"description"], @"");
            
            [expectation fulfill];
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);
            
            [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

-(void)testLocationSearchReturnsError {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [self.client fetchEntriesMatching:@{ @"fields.location[near]": @[ @(23), @(42) ],
                                         @"content_type": @"restaurant" }
        success:^(CDAResponse *response, CDAArray *array) {
            XCTFail(@"Query should fail.");
        } failure:^(CDAResponse *response, NSError *error) {
            XCTAssertEqualObjects(@"CDAErrorDomain", error.domain, @"");
            XCTAssertEqual(400, error.code, @"");
            XCTAssertEqualObjects(@"The query you sent was invalid. Probably a filter or ordering specification is not applicable to the type of a field.", error.localizedDescription, @"");
            XCTAssertEqualObjects((@{ @"errors": @[ @{ @"name": @"unknownContentType",
                                                       @"value": @"DOESNOTEXIST" } ] }),
                                  error.userInfo[@"details"], @"");
            XCTAssertEqualObjects(@"InvalidQuery", error.userInfo[@"identifier"], @"");
            
            [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testSearchOrder {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [self.client fetchEntriesMatching:@{ @"order": @"sys.createdAt" }
        success:^(CDAResponse *response, CDAArray *array) {
            XCTAssertEqualObjects(@"nyancat", [[array.items firstObject] identifier], @"");
            XCTAssertEqualObjects(@"7qVBlCjpWE86Oseo40gAEY",
                                  [[array.items lastObject] identifier], @"");
            
            [expectation fulfill];
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);
            
            [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testSearchOrderReversed {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [self.client fetchEntriesMatching:@{ @"order": @"-sys.updatedAt" }
        success:^(CDAResponse *response, CDAArray *array) {
            XCTAssertEqualObjects(@"5ETMRzkl9KM4omyMwKAOki",
                                  [[array.items firstObject] identifier], @"");
            XCTAssertEqualObjects(@"garfield", [[array.items lastObject] identifier], @"");
                                  
            [expectation fulfill];
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);
                                  
            [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testSearchLimit {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [self.client fetchEntriesMatching:@{ @"limit": @3 }
                              success:^(CDAResponse *response, CDAArray *array) {
                                  XCTAssertEqual(3U, array.items.count, @"");
                                  XCTAssertEqual(3U, array.limit, @"");
                                  
                                  [expectation fulfill];
                              } failure:^(CDAResponse *response, NSError *error) {
                                  XCTFail(@"Error: %@", error);
                                  
                                  [expectation fulfill];
                              }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

// FIXME: Source space has been deleted, test data needs to be recreated
#if 0
- (void)testSearchLimitZero {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    CDAConfiguration* configuration = [CDAConfiguration defaultConfiguration];
    configuration.server = @"cdn.flinkly.com";
    
    CDAClient* client = [[CDAClient alloc] initWithSpaceKey:@"3vysoudsmwwo" accessToken:@"8efdb99a1b33b21edd6bd6f68aa702a0d688b4a4433ac3327d234a28ed825ca2" configuration:configuration];
    
    [client fetchEntriesMatching:@{ @"limit": @0 }
                         success:^(CDAResponse *response, CDAArray *array) {
                             XCTAssertEqual(0U, array.items.count, @"");
                             XCTAssertEqual(0U, array.limit, @"");
                             XCTAssertEqual(4U, array.total, @"");
                             
                             [expectation fulfill];
                         } failure:^(CDAResponse *response, NSError *error) {
                             XCTFail(@"Error: %@", error);
                             
                             [expectation fulfill];
                         }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}
#endif

- (void)testSearchSkip {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [self.client fetchEntriesMatching:@{ @"skip": @3 }
                              success:^(CDAResponse *response, CDAArray *array) {
                                  XCTAssertEqual(7U, array.items.count, @"");
                                  XCTAssertEqual(3U, array.skip, @"");
                                  
                                  [expectation fulfill];
                              } failure:^(CDAResponse *response, NSError *error) {
                                  XCTFail(@"Error: %@", error);
                                  
                                  [expectation fulfill];
                              }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testIncludes {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [self.client fetchEntriesMatching:@{ @"sys.id": @"nyancat", @"include": @(1) }
                              success:^(CDAResponse *response, CDAArray *array) {
                                  XCTAssertEqual(1U, array.items.count, @"");
                                  CDAEntry* nyanCat = [array.items firstObject];
                                  XCTAssertEqualObjects(@"image/png", [nyanCat.fields[@"image"] MIMEType], @"");
                                  XCTAssertEqualObjects(@"happycat", [nyanCat.fields[@"bestFriend"] identifier], @"");
                                  
                                  [expectation fulfill];
                              } failure:^(CDAResponse *response, NSError *error) {
                                  XCTFail(@"Error: %@", error);
                                  
                                  [expectation fulfill];
                              }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

@end
