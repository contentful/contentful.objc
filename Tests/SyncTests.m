//
//  SyncTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 25/03/14.
//
//

#import <OHHTTPStubs/OHHTTPStubs.h>

#import "CDAResource+Private.h"
#import "ContentfulBaseTestCase.h"

@interface SyncTests : ContentfulBaseTestCase

@end

#pragma mark -

@implementation SyncTests

-(void)setUp {
    [super setUp];
    
    self.client = [[CDAClient alloc] initWithSpaceKey:@"emh6o2ireilu" accessToken:@"1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac"];

    CDAContentType* ct = [[CDAContentType alloc] initWithDictionary:@{ @"sys": @{ @"id": @"6bAvxqodl6s4MoKuWYkmqe" }, @"name": @"Stub", @"fields": @[ @{ @"id": @"title", @"type": @"Symbol" }, @{ @"id": @"body", @"type": @"Text" } ] } client:self.client];
    ct = nil;
    
    /* 
     Map URLs to JSON response files
     
     The tests are based on a sync session with four subsequent syncs where each one either added or
     removed one Resource.
     */
    NSDictionary* stubs = @{ @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?access_token=1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac&initial=true": @"initial", @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?access_token=1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac&sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyYxwoHDtsKywrXDmQs_WcOvIcOzwotYw6PCgcOsAcOYYcO4YsKCw7TCnsK_clnClS7Csx9lwoFcw6nCqnnCpWh3w7k7SkI-CcOuQyXDlw_Dlh9RwqkcElwpW30sw4k": @"added", @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?access_token=1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac&sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyY0w4bCiMKOWDIFw61bwqQ_w73CnMKsB8KpwrFZPsOZw5ZQwqDDnUA0w5tOPRtwwoAkwpJMTzghdEnDjCkiw5fCuynDlsO5DyvCsjgQa2TDisKNZ8Kqw4TCjhZIGQ": @"deleted", @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?access_token=1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac&sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyZew5xDN04dJg3DkmBAw4XDh8OEw5o5UVhIw6nDlFjDoBxIasKIDsKIw4VcIV18GicdwoTDjCtoMiFAfcKiwrRKIsKYwrzCmMKBw4ZhwrdhwrsGa8KTwpQ6w6A": @"added-asset", @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?access_token=1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac&sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyZ_NnHDoQzCtcKoMh9KZHtAWcObw7XCimZgVGPChUfDuxQHwoHDosO6CcKodsO2MWJQwrrCrsOswpl5w6LCuV0tw4Njwo9Ww5fCl8KqEgB6XgAJNVF2wpk3Lg": @"deleted-asset" };
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSString* JSONName = stubs[request.URL.absoluteString];
        
        if (JSONName) {
            return [OHHTTPStubsResponse responseWithFileAtPath:[[NSBundle bundleForClass:[self class]] pathForResource:JSONName ofType:@"json" inDirectory:@"SyncTests"] statusCode:200 headers:@{ @"Content-Type": @"application/vnd.contentful.delivery.v1+json" }];
        }
        
        return [OHHTTPStubsResponse responseWithData:nil statusCode:200 headers:nil];
    }];
}

-(void)tearDown {
    [OHHTTPStubs removeAllStubs];
}

-(void)testInitialSync {
    StartBlock();
    
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response, CDASyncedSpace *space) {
        XCTAssertEqual(1U, space.assets.count, @"");
        XCTAssertEqual(1U, space.entries.count, @"");
        
        CDAEntry* entry = [space.entries firstObject];
        XCTAssertEqualObjects(@"Test", entry.fields[@"title"], @"");
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    XCTAssertNotNil(request, @"");
    
    WaitUntilBlockCompletes();
}

-(void)testSyncAddAsset {
    StartBlock();
    
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response,
                                                                           CDASyncedSpace *space) {
        [space performSynchronizationWithSuccess:^{
            XCTAssertEqual(1U, space.assets.count, @"");
            XCTAssertEqual(2U, space.entries.count, @"");
            
            [space performSynchronizationWithSuccess:^{
                XCTAssertEqual(1U, space.assets.count, @"");
                XCTAssertEqual(1U, space.entries.count, @"");
                
                [space performSynchronizationWithSuccess:^{
                    XCTAssertEqual(2U, space.assets.count, @"");
                    XCTAssertEqual(1U, space.entries.count, @"");
                    
                    CDAAsset* asset = [space.assets lastObject];
                    XCTAssertEqualObjects(@"6koKmTXVzUquae6ewQQ8Eu", asset.identifier, @"");
                    
                    EndBlock();
                } failure:^(CDAResponse *response, NSError *error) {
                    XCTFail(@"Error: %@", error);
                    
                    EndBlock();
                }];
            } failure:^(CDAResponse *response, NSError *error) {
                XCTFail(@"Error: %@", error);
                
                EndBlock();
            }];
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);
            
            EndBlock();
        }];
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    XCTAssertNotNil(request, @"");
    
    WaitUntilBlockCompletes();
}

-(void)testSyncRemoveAsset {
    StartBlock();
    
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response,
                                                                           CDASyncedSpace *space) {
        [space performSynchronizationWithSuccess:^{
            XCTAssertEqual(1U, space.assets.count, @"");
            XCTAssertEqual(2U, space.entries.count, @"");
            
            [space performSynchronizationWithSuccess:^{
                XCTAssertEqual(1U, space.assets.count, @"");
                XCTAssertEqual(1U, space.entries.count, @"");
                
                [space performSynchronizationWithSuccess:^{
                    XCTAssertEqual(2U, space.assets.count, @"");
                    XCTAssertEqual(1U, space.entries.count, @"");
                    
                    [space performSynchronizationWithSuccess:^{
                        XCTAssertEqual(1U, space.assets.count, @"");
                        XCTAssertEqual(1U, space.entries.count, @"");
                        
                        CDAAsset* asset = [space.assets firstObject];
                        XCTAssertEqualObjects(@"6koKmTXVzUquae6ewQQ8Eu", asset.identifier, @"");
                        
                        EndBlock();
                    } failure:^(CDAResponse *response, NSError *error) {
                        XCTFail(@"Error: %@", error);
                        
                        EndBlock();
                    }];
                } failure:^(CDAResponse *response, NSError *error) {
                    XCTFail(@"Error: %@", error);
                    
                    EndBlock();
                }];
            } failure:^(CDAResponse *response, NSError *error) {
                XCTFail(@"Error: %@", error);
                
                EndBlock();
            }];
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);
            
            EndBlock();
        }];
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    XCTAssertNotNil(request, @"");
    
    WaitUntilBlockCompletes();
}

-(void)testSyncAddEntry {
    StartBlock();
    
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response,
                                                                           CDASyncedSpace *space) {
        [space performSynchronizationWithSuccess:^{
            XCTAssertEqual(1U, space.assets.count, @"");
            XCTAssertEqual(2U, space.entries.count, @"");
            
            CDAEntry* entry = space.entries[1];
            XCTAssertEqualObjects(@"Second entry", entry.fields[@"title"], @"");
            XCTAssertEqualObjects(@"some text", entry.fields[@"body"], @"");
            
            EndBlock();
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);
            
            EndBlock();
        }];
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    XCTAssertNotNil(request, @"");
    
    WaitUntilBlockCompletes();
}

-(void)testSyncRemoveEntry {
    StartBlock();
    
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response,
                                                                           CDASyncedSpace *space) {
        [space performSynchronizationWithSuccess:^{
            XCTAssertEqual(1U, space.assets.count, @"");
            XCTAssertEqual(2U, space.entries.count, @"");
            
            [space performSynchronizationWithSuccess:^{
                XCTAssertEqual(1U, space.assets.count, @"");
                XCTAssertEqual(1U, space.entries.count, @"");
                
                CDAEntry* entry = [space.entries firstObject];
                XCTAssertEqualObjects(@"Test", entry.fields[@"title"], @"");
                
                EndBlock();
            } failure:^(CDAResponse *response, NSError *error) {
                XCTFail(@"Error: %@", error);
                
                EndBlock();
            }];
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);
            
            EndBlock();
        }];
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    XCTAssertNotNil(request, @"");
    
    WaitUntilBlockCompletes();
}

@end
