//
//  LinkTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 24/03/14.
//
//

#import "CDAResource+Private.h"
#import "ContentfulBaseTestCase.h"

@interface LinkTests : ContentfulBaseTestCase

@end

#pragma mark -

@implementation LinkTests

-(void)testResolveArrayOfLinks {
    NSArray* assetArray = @[ [[CDAAsset alloc] initWithDictionary:@{ @"sys": @{ @"id": @"nyancat", @"type": @"Link" } } client:self.client localizationAvailable:NO], [[CDAAsset alloc] initWithDictionary:@{ @"sys": @{ @"id": @"happycat", @"type": @"Link" } } client:self.client localizationAvailable:NO] ];
    
    for (CDAAsset* asset in assetArray) {
        XCTAssertFalse(asset.fetched, @"");
        XCTAssertNil(asset.URL, @"");
    }
    
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [self.client resolveLinksFromArray:assetArray success:^(NSArray *items) {
        items = [items sortedArrayUsingComparator:^NSComparisonResult(CDAAsset* asset1,
                                                                      CDAAsset* asset2) {
            return [asset1.identifier compare:asset2.identifier];
        }];
        
        XCTAssertEqualObjects(@"happycatw.jpg", [[items[0] URL] lastPathComponent], @"");
        XCTAssertEqualObjects(@"Nyan_cat_250px_frame.png", [[items[1] URL] lastPathComponent], @"");
        
        [expectation fulfill];
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

-(void)testResolveAssetLink {
    CDAAsset* asset = [[CDAAsset alloc] initWithDictionary:@{ @"sys": @{ @"id": @"nyancat",
                                                                         @"type": @"Link" } }
                                                    client:self.client
                                     localizationAvailable:NO];
    XCTAssertFalse(asset.fetched, @"");
    XCTAssertNil(asset.URL, @"");
    
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [asset resolveWithSuccess:^(CDAResponse *response, CDAResource *resource) {
        CDAAsset* asset = (CDAAsset*)resource;
        XCTAssertEqualObjects(@"Nyan_cat_250px_frame.png", [asset.URL lastPathComponent], @"");
        
        [asset resolveWithSuccess:^(CDAResponse *response, CDAResource *resource) {
            CDAAsset* asset = (CDAAsset*)resource;
            XCTAssertEqualObjects(@"Nyan_cat_250px_frame.png", [asset.URL lastPathComponent], @"");
            
            [expectation fulfill];
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);
            
            [expectation fulfill];
        }];
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

-(void)testResolveContentTypeLink {
    CDAContentType* contentType = [[CDAContentType alloc] initWithDictionary:@{ @"sys": @{ @"id": @"cat", @"type": @"Link" }, @"name": @"ct" } client:self.client localizationAvailable:NO];
    XCTAssertFalse(contentType.fetched, @"");
    XCTAssertEqual(0U, contentType.fields.count, @"");
    
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [contentType resolveWithSuccess:^(CDAResponse *response, CDAResource *resource) {
        CDAContentType* contentType = (CDAContentType*)resource;
        XCTAssertEqual(8U, contentType.fields.count, @"");
        XCTAssertEqualObjects(@"Cat", contentType.name, @"");
        
        [contentType resolveWithSuccess:^(CDAResponse *response, CDAResource *resource) {
            XCTAssertEqual(8U, contentType.fields.count, @"");
            XCTAssertEqualObjects(@"Cat", contentType.name, @"");
            
            [expectation fulfill];
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);
            
            [expectation fulfill];
        }];
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

-(void)testResolveEntry {
    CDAEntry* entry = [[CDAEntry alloc] initWithDictionary:@{ @"sys": @{ @"id": @"nyancat",
                                                                         @"type": @"Link" } }
                                                    client:self.client
                                     localizationAvailable:NO];
    XCTAssertFalse(entry.fetched, @"");
    XCTAssertEqual(0U, entry.fields.count, @"");
    
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [entry resolveWithSuccess:^(CDAResponse *response, CDAResource *resource) {
        CDAEntry* entry = (CDAEntry*)resource;
        XCTAssertEqual(7U, entry.fields.count, @"");
        XCTAssertEqualObjects(@"Nyan Cat", entry.fields[@"name"], @"");
        XCTAssertNotNil(entry.contentType, @"");
        
        [entry resolveWithSuccess:^(CDAResponse *response, CDAResource *resource) {
            XCTAssertEqual(7U, entry.fields.count, @"");
            XCTAssertEqualObjects(@"Nyan Cat", entry.fields[@"name"], @"");
            XCTAssertNotNil(entry.contentType, @"");
            
            [expectation fulfill];
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);
            
            [expectation fulfill];
        }];
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

-(void)testResolveResource {
    CDAResource* resource = [[CDAResource alloc] initWithDictionary:@{ @"sys": @{ @"id": @"nyancat",
                                                                                  @"type": @"Entry" } }
                                                             client:self.client
                                              localizationAvailable:NO];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [resource resolveWithSuccess:^(CDAResponse *response, CDAResource *resource) {
        [expectation fulfill];
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

-(void)testUnimplementedResolveThrows {
    CDAResource* resource = [[CDAResource alloc] initWithDictionary:@{ @"sys": @{ @"id": @"nyancat",
                                                                                  @"type": @"Link" } }
                                                             client:self.client
                                              localizationAvailable:NO];
    
    XCTAssertThrowsSpecificNamed([resource resolveWithSuccess:^(CDAResponse* a, CDAResource* b) {
    } failure:^(CDAResponse* a, NSError* b) {}], NSException, NSInternalInconsistencyException, @"");
}

@end
