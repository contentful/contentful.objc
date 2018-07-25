//
//  StagingTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 06/03/14.
//
//

#import "ContentfulBaseTestCase.h"

@interface StagingTests : ContentfulBaseTestCase

@end

#pragma mark -

@implementation StagingTests

// FIXME: Source space has been deleted, test data needs to be recreated
#if 0
- (void)setUp
{
    [super setUp];
    
    CDAConfiguration* configuration = [CDAConfiguration defaultConfiguration];
    configuration.server = @"cdn.flinkly.com";
    
    self.client = [[CDAClient alloc] initWithSpaceKey:@"3vysoudsmwwo" accessToken:@"8efdb99a1b33b21edd6bd6f68aa702a0d688b4a4433ac3327d234a28ed825ca2" configuration:configuration];
}

- (void)testContentTypes {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [self.client fetchContentTypesWithSuccess:^(CDAResponse *response, CDAArray *array) {
        XCTAssertNotNil(array, @"");
        
        [expectation fulfill];
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testEntries {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [self.client fetchEntriesWithSuccess:^(CDAResponse *response, CDAArray *array) {
        XCTAssertNotNil(array, @"");
        
        [expectation fulfill];
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}
#endif

@end
