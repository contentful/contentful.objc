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
    NSArray* assetArray = @[ [[CDAAsset alloc] initWithDictionary:@{ @"sys": @{ @"id": @"nyancat", @"type": @"Link" } } client:self.client], [[CDAAsset alloc] initWithDictionary:@{ @"sys": @{ @"id": @"happycat", @"type": @"Link" } } client:self.client] ];
    
    for (CDAAsset* asset in assetArray) {
        XCTAssertFalse(asset.fetched, @"");
        XCTAssertNil(asset.URL, @"");
    }
    
    StartBlock();
    
    [self.client resolveLinksFromArray:assetArray success:^(NSArray *items) {
        items = [items sortedArrayUsingComparator:^NSComparisonResult(CDAAsset* asset1,
                                                                      CDAAsset* asset2) {
            return [asset1.identifier compare:asset2.identifier];
        }];
        
        XCTAssertEqualObjects(@"happycatw.jpg", [[items[0] URL] lastPathComponent], @"");
        XCTAssertEqualObjects(@"Nyan_cat_250px_frame.png", [[items[1] URL] lastPathComponent], @"");
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

-(void)testResolveAssetLink {
    CDAAsset* asset = [[CDAAsset alloc] initWithDictionary:@{ @"sys": @{ @"id": @"nyancat",
                                                                         @"type": @"Link" } }
                                                    client:self.client];
    XCTAssertFalse(asset.fetched, @"");
    XCTAssertNil(asset.URL, @"");
    
    StartBlock();
    
    [asset resolveWithSuccess:^(CDAResponse *response, CDAResource *resource) {
        CDAAsset* asset = (CDAAsset*)resource;
        XCTAssertEqualObjects(@"Nyan_cat_250px_frame.png", [asset.URL lastPathComponent], @"");
        
        [asset resolveWithSuccess:^(CDAResponse *response, CDAResource *resource) {
            CDAAsset* asset = (CDAAsset*)resource;
            XCTAssertEqualObjects(@"Nyan_cat_250px_frame.png", [asset.URL lastPathComponent], @"");
            
            EndBlock();
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);
            
            EndBlock();
        }];
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

-(void)testResolveContentTypeLink {
    CDAContentType* contentType = [[CDAContentType alloc] initWithDictionary:@{ @"sys": @{ @"id": @"cat", @"type": @"Link" }, @"name": @"ct" } client:self.client];
    XCTAssertFalse(contentType.fetched, @"");
    XCTAssertEqual(0U, contentType.fields.count, @"");
    
    StartBlock();
    
    [contentType resolveWithSuccess:^(CDAResponse *response, CDAResource *resource) {
        CDAContentType* contentType = (CDAContentType*)resource;
        XCTAssertEqual(8U, contentType.fields.count, @"");
        XCTAssertEqualObjects(@"Cat", contentType.name, @"");
        
        [contentType resolveWithSuccess:^(CDAResponse *response, CDAResource *resource) {
            XCTAssertEqual(8U, contentType.fields.count, @"");
            XCTAssertEqualObjects(@"Cat", contentType.name, @"");
            
            EndBlock();
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);
            
            EndBlock();
        }];
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

-(void)testResolveEntry {
    CDAEntry* entry = [[CDAEntry alloc] initWithDictionary:@{ @"sys": @{ @"id": @"nyancat",
                                                                         @"type": @"Link" } }
                                                    client:self.client];
    XCTAssertFalse(entry.fetched, @"");
    XCTAssertEqual(0U, entry.fields.count, @"");
    
    StartBlock();
    
    [entry resolveWithSuccess:^(CDAResponse *response, CDAResource *resource) {
        CDAEntry* entry = (CDAEntry*)resource;
        XCTAssertEqual(7U, entry.fields.count, @"");
        XCTAssertEqualObjects(@"Nyan Cat", entry.fields[@"name"], @"");
        XCTAssertNotNil(entry.contentType, @"");
        
        [entry resolveWithSuccess:^(CDAResponse *response, CDAResource *resource) {
            XCTAssertEqual(7U, entry.fields.count, @"");
            XCTAssertEqualObjects(@"Nyan Cat", entry.fields[@"name"], @"");
            XCTAssertNotNil(entry.contentType, @"");
            
            EndBlock();
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);
            
            EndBlock();
        }];
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

-(void)testResolveResource {
    CDAResource* resource = [[CDAResource alloc] initWithDictionary:@{ @"sys": @{ @"id": @"nyancat",
                                                                                  @"type": @"Entry" } }
                                                             client:self.client];
    
    StartBlock();
    
    [resource resolveWithSuccess:^(CDAResponse *response, CDAResource *resource) {
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

-(void)testUnimplementedResolveThrows {
    CDAResource* resource = [[CDAResource alloc] initWithDictionary:@{ @"sys": @{ @"id": @"nyancat",
                                                                                  @"type": @"Link" } }
                                                             client:self.client];
    
    XCTAssertThrowsSpecificNamed([resource resolveWithSuccess:nil failure:nil], NSException,
                                 NSInternalInconsistencyException, @"");
}

@end
