//
//  ArrayTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 12/03/14.
//
//

#import "CDAUtilities.h"
#import "ContentfulBaseTestCase.h"

@interface ArrayTests : ContentfulBaseTestCase

@end

#pragma mark -

@implementation ArrayTests

- (void)setUp {
    [super setUp];
    
    self.client = [[CDAClient alloc] initWithSpaceKey:@"lzjz8hygvfgu" accessToken:@"0c6ef483524b5e46b3bafda1bf355f38f5f40b4830f7599f790a410860c7c271"];
}

- (void)testFetchResourcesOfTypeAsset {
    StartBlock();
    
    [self.client fetchResourcesOfType:CDAResourceTypeAsset
                             matching:nil
                              success:^(CDAResponse *response, CDAArray *array) {
                                  XCTAssertEqual(0U, array.items.count, @"");
                                  
                                  EndBlock();
                              }
                              failure:^(CDAResponse *response, NSError *error) {
                                  XCTFail(@"%@", error);
                                  
                                  EndBlock();
                              }];
    
    WaitUntilBlockCompletes();
}

- (void)testFetchResourcesOfTypeContentType {
    StartBlock();
    
    [self.client fetchResourcesOfType:CDAResourceTypeContentType
                             matching:nil
                              success:^(CDAResponse *response, CDAArray *array) {
                                  XCTAssertEqual(2U, array.items.count, @"");
                                  
                                  for (CDAContentType* ct in array.items) {
                                      XCTAssert(CDAClassIsOfType([ct class], CDAContentType.class));
                                  }
                                  
                                  EndBlock();
                              }
                              failure:^(CDAResponse *response, NSError *error) {
                                  XCTFail(@"%@", error);
                                  
                                  EndBlock();
                              }];
    
    WaitUntilBlockCompletes();
}

- (void)testFetchResourcesOfTypeEntry {
    StartBlock();
    
    [self.client fetchResourcesOfType:CDAResourceTypeEntry
                             matching:nil
                              success:^(CDAResponse *response, CDAArray *array) {
                                  XCTAssertEqual(100U, array.items.count, @"");
                                  
                                  for (CDAEntry* entry in array.items) {
                                      XCTAssert(CDAClassIsOfType([entry class], CDAEntry.class));
                                  }
                                  
                                  EndBlock();
                              }
                              failure:^(CDAResponse *response, NSError *error) {
                                  XCTFail(@"%@", error);
                                  
                                  EndBlock();
                              }];
    
    WaitUntilBlockCompletes();
}

- (void)testIncludes {
    StartBlock();
    
    self.client = [[CDAClient alloc] initWithSpaceKey:@"b61be4nhwivb" accessToken:@"92df7fe7c01a0429a8d22a1cd6173a7f05a7313835202ae1170158825d35e64f"];
    [self.client fetchEntriesMatching:@{ @"content_type": @"1IXmNJUSVOcuCiKaQUiSO4", @"include": @1 } success:^(CDAResponse *response, CDAArray *array) {
        XCTAssertEqual(1U, array.items.count, @"");
        
        CDAEntry* entry = [array.items firstObject];
        XCTAssertEqualObjects(@"some post", entry.fields[@"title"], @"");
        
        NSArray* linkedEntries = entry.fields[@"tags"];
        XCTAssertEqual(2U, linkedEntries.count, @"");
        for (CDAEntry* linkedEntry in linkedEntries) {
            NSString* name = linkedEntry.fields[@"name"];
            XCTAssert([name isEqualToString:@"foo"] || [name isEqualToString:@"bar"],
                      @"Unexpected name '%@'", name);
        }
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"%@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

- (void)testPaging {
    StartBlock();
    
    [self.client fetchEntriesMatching:@{ @"content_type": @"7ocuA1dfoccWqWwWUY4UY" }
                              success:^(CDAResponse *response, CDAArray *array) {
                                  [self.client fetchAllItemsFromArray:array
                                                              success:^(NSArray *items) {
                                                                  XCTAssertEqual(590U,
                                                                                 items.count,
                                                                                 @"");
                                                                  
                                                                  EndBlock();
                                                              } failure:^(CDAResponse *response,
                                                                          NSError *error) {
                                                                  XCTFail(@"%@", error);
                                                                  
                                                                  EndBlock();
                                                              }];
                              } failure:^(CDAResponse *response, NSError *error) {
                                  XCTFail(@"%@", error);
                                  
                                  EndBlock();
                              }];
    
    WaitUntilBlockCompletes();
}

- (void)testRequest {
    StartBlock();
    
    __block CDARequest* request = [self.client fetchSpaceWithSuccess:^(CDAResponse *response,
                                                               CDASpace *space) {
        XCTAssertEqual(request.response.statusCode, response.statusCode, @"");
        XCTAssertEqualObjects([NSURL URLWithString:@"https://cdn.contentful.com/spaces/lzjz8hygvfgu/"], request.request.URL, @"");
        XCTAssertNil(request.error, @"");
        XCTAssertEqual((NSUInteger)NSUTF8StringEncoding,
                       (NSUInteger)request.responseStringEncoding, @"");
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"%@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

@end
