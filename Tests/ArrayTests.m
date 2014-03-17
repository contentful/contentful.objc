//
//  ArrayTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 12/03/14.
//
//

#import "ContentfulBaseTestCase.h"

@interface ArrayTests : ContentfulBaseTestCase

@end

#pragma mark -

@implementation ArrayTests

- (void)setUp {
    [super setUp];
    
    self.client = [[CDAClient alloc] initWithSpaceKey:@"lzjz8hygvfgu" accessToken:@"0c6ef483524b5e46b3bafda1bf355f38f5f40b4830f7599f790a410860c7c271"];
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
        XCTAssertEqualObjects([NSURL URLWithString:@"https://cdn.contentful.com/spaces/lzjz8hygvfgu/?access_token=0c6ef483524b5e46b3bafda1bf355f38f5f40b4830f7599f790a410860c7c271"], request.request.URL, @"");
        XCTAssertNil(request.error, @"");
        XCTAssertNotNil(request.responseData, @"");
        XCTAssertNotNil(request.responseObject, @"");
        XCTAssertNotNil(request.responseString, @"");
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
