//
//  SyncTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 25/03/14.
//
//

#import <OCMock/OCMock.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

#import "CDADeletedAsset.h"
#import "CDADeletedEntry.h"
#import "CDAResource+Private.h"
#import "ContentfulBaseTestCase.h"

@interface SyncedSpaceDelegate : NSObject <CDASyncedSpaceDelegate>

@end

#pragma mark -

@implementation SyncedSpaceDelegate

@end

#pragma mark -

@interface SyncTests : ContentfulBaseTestCase <CDASyncedSpaceDelegate>

@property (nonatomic) BOOL expectFieldsInDeletedResources;
@property (nonatomic) NSUInteger numberOfDelegateMethodCalls;
@property (nonatomic) BOOL waiting;

@end

#pragma mark -

@implementation SyncTests

-(void)addDummyContentType {
    CDAContentType* ct = [[CDAContentType alloc] initWithDictionary:@{ @"sys": @{ @"id": @"6bAvxqodl6s4MoKuWYkmqe" }, @"name": @"Stub", @"fields": @[ @{ @"id": @"title", @"type": @"Symbol" }, @{ @"id": @"body", @"type": @"Text" } ] } client:self.client];
    ct = nil;
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object change:(NSDictionary *)change
                      context:(void *)context {
    XCTAssert([keyPath isEqualToString:@"assets"] || [keyPath isEqualToString:@"entries"], @"");
    
    self.waiting = NO;
}

-(void)setUp {
    [super setUp];
    
    self.client = [[CDAClient alloc] initWithSpaceKey:@"emh6o2ireilu" accessToken:@"1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac"];
    self.expectFieldsInDeletedResources = NO;
    self.numberOfDelegateMethodCalls = 0;
    self.waiting = YES;

    [self addDummyContentType];
    
    /* 
     Map URLs to JSON response files
     
     The tests are based on a sync session with five subsequent syncs where each one either added,
     removed or updated Resources.
     */
    NSDictionary* stubs = @{ @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?access_token=1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac&initial=true": @"initial", @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?access_token=1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac&sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyYxwoHDtsKywrXDmQs_WcOvIcOzwotYw6PCgcOsAcOYYcO4YsKCw7TCnsK_clnClS7Csx9lwoFcw6nCqnnCpWh3w7k7SkI-CcOuQyXDlw_Dlh9RwqkcElwpW30sw4k": @"added", @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?access_token=1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac&sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyY0w4bCiMKOWDIFw61bwqQ_w73CnMKsB8KpwrFZPsOZw5ZQwqDDnUA0w5tOPRtwwoAkwpJMTzghdEnDjCkiw5fCuynDlsO5DyvCsjgQa2TDisKNZ8Kqw4TCjhZIGQ": @"deleted", @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?access_token=1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac&sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyZew5xDN04dJg3DkmBAw4XDh8OEw5o5UVhIw6nDlFjDoBxIasKIDsKIw4VcIV18GicdwoTDjCtoMiFAfcKiwrRKIsKYwrzCmMKBw4ZhwrdhwrsGa8KTwpQ6w6A": @"added-asset", @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?access_token=1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac&sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyZ_NnHDoQzCtcKoMh9KZHtAWcObw7XCimZgVGPChUfDuxQHwoHDosO6CcKodsO2MWJQwrrCrsOswpl5w6LCuV0tw4Njwo9Ww5fCl8KqEgB6XgAJNVF2wpk3Lg": @"deleted-asset", @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?access_token=1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac&sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyYHPUPDhggxwr5qw5RBbMKWw4VjOg3DumTDg0_CgsKcYsO8UcOZfMKLw4sKUcOnJcKxfDUkGWwxNMOVw4AiacK5Bmo4ScOhI0g2cXLClxTClsOyE8OOc8O3": @"update", @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?access_token=something&initial=true": @"initialWithoutToken", @"https://cdn.contentful.com/spaces/emh6o2ireilu/?access_token=1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac": @"space", @"https://cdn.contentful.com/spaces/emh6o2ireilu/?access_token=something": @"space", };
    
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

-(void)testContinueSyncWithoutSyncSpaceInstance {
    __block BOOL contentTypesWereFetched = NO;
    
    StartBlock();
    
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response, CDASyncedSpace *space) {
        XCTAssertEqual(1U, space.assets.count, @"");
        XCTAssertEqual(1U, space.entries.count, @"");
        
        NSString* syncToken = space.syncToken;
        space = nil;
        XCTAssertNil(space, @"");
        
        self.client = [[CDAClient alloc] initWithSpaceKey:@"emh6o2ireilu" accessToken:@"1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac"];
        
        // Mock the Content Type retrieval
        self.client = [OCMockObject partialMockForObject:self.client];
        [[[(OCMockObject*)self.client stub] andDo:^(NSInvocation *invocation) {
            CDAArrayFetchedBlock successBlock;
            [invocation getArgument:&successBlock atIndex:2];
            
            [self.client fetchSpaceWithSuccess:^(CDAResponse *response, CDASpace *space) {
                [self addDummyContentType];
                
                contentTypesWereFetched = YES;
                successBlock(nil, nil);
            } failure:^(CDAResponse *response, NSError *error) {
                XCTFail(@"Error: %@", error);
                
                EndBlock();
            }];
        }] fetchContentTypesWithSuccess:[OCMArg any] failure:[OCMArg any]];
        
        CDASyncedSpace* shallowSyncSpace = [CDASyncedSpace shallowSyncSpaceWithToken:syncToken
                                                                              client:self.client];
        shallowSyncSpace.delegate = self;
        
        [shallowSyncSpace performSynchronizationWithSuccess:^{
            XCTAssertNil(shallowSyncSpace.assets, @"");
            XCTAssertNil(shallowSyncSpace.entries, @"");
            
            [shallowSyncSpace performSynchronizationWithSuccess:^{
                XCTAssertNil(shallowSyncSpace.assets, @"");
                XCTAssertNil(shallowSyncSpace.entries, @"");
                
                [shallowSyncSpace performSynchronizationWithSuccess:^{
                    XCTAssertNil(shallowSyncSpace.assets, @"");
                    XCTAssertNil(shallowSyncSpace.entries, @"");
                    
                    [shallowSyncSpace performSynchronizationWithSuccess:^{
                        XCTAssertNil(shallowSyncSpace.assets, @"");
                        XCTAssertNil(shallowSyncSpace.entries, @"");
                        
                        [shallowSyncSpace performSynchronizationWithSuccess:^{
                            XCTAssertNil(shallowSyncSpace.assets, @"");
                            XCTAssertNil(shallowSyncSpace.entries, @"");
                            
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
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    XCTAssertNotNil(request, @"");
    
    WaitUntilBlockCompletes();
    
    XCTAssertEqual(6U, self.numberOfDelegateMethodCalls, @"");
    XCTAssert(contentTypesWereFetched, @"Content Types were not fetched.");
}

-(void)testDelegateIsActuallyOptional {
    StartBlock();
    
    SyncedSpaceDelegate* delegate = [SyncedSpaceDelegate new];
    
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response,
                                                                           CDASyncedSpace *space) {
        space.delegate = delegate;
        
        [space performSynchronizationWithSuccess:^{
            [space performSynchronizationWithSuccess:^{
                [space performSynchronizationWithSuccess:^{
                    [space performSynchronizationWithSuccess:^{
                        [space performSynchronizationWithSuccess:^{
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
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    XCTAssertNotNil(request, @"");
    
    WaitUntilBlockCompletes();
    
    XCTAssertNotNil(delegate, @"");
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
    
    XCTAssertEqual(0U, self.numberOfDelegateMethodCalls, @"");
}

-(void)testAssetWithMultipleLocalesWhileSyncing {
    [OHHTTPStubs removeAllStubs];
    
    StartBlock();
    
    CDAConfiguration* configuration = [CDAConfiguration defaultConfiguration];
    configuration.server = @"cdn.flinkly.com";
    self.client = [[CDAClient alloc] initWithSpaceKey:@"0be4dalv8pk7" accessToken:@"062472725a8cbf6f11b0e0c63c616e321a9e245b1bf1a0f9b34cfd42162d5b0f" configuration:configuration];
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response, CDASyncedSpace *space) {
        CDAAsset* asset = [space.assets firstObject];
        
        XCTAssertEqualObjects(@"foo", asset.fields[@"title"], @"");
        XCTAssertEqualObjects(@"512_black.png", asset.URL.lastPathComponent, @"");
        
        asset.locale = @"de-DE";
        XCTAssertEqualObjects(@"bar", asset.fields[@"title"], @"");
        XCTAssertEqualObjects(@"SeaLionWallpaper.jpg", asset.URL.lastPathComponent, @"");
        
        asset.locale = @"tlh";
        XCTAssertEqualObjects(@"foo", asset.fields[@"title"], @"");
        XCTAssertEqualObjects(@"512_black.png", asset.URL.lastPathComponent, @"");
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    XCTAssertNotNil(request, @"");
    
    WaitUntilBlockCompletes();
}

-(void)testEntryWithMultipleLocalesWhileSyncing {
    [OHHTTPStubs removeAllStubs];
    
    StartBlock();
    
    self.client = [[CDAClient alloc] initWithSpaceKey:@"cfexampleapi" accessToken:@"b4c0n73n7fu1"];
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response, CDASyncedSpace *space) {
        CDAEntry* nyanCat = nil;
        
        for (CDAEntry* entry in space.entries) {
            if ([entry.identifier isEqualToString:@"nyancat"]) {
                nyanCat = entry;
                break;
            }
        }
        
        XCTAssertNotNil(nyanCat, @"Response did not contain expected entries.");
        XCTAssertEqualObjects(@"Nyan Cat", nyanCat.fields[@"name"], @"");
        XCTAssertNotNil([nyanCat.fields[@"image"] URL], @"");
        
        nyanCat.locale = @"tlh";
        XCTAssertEqualObjects(@"Nyan vIghro'", nyanCat.fields[@"name"], @"");
        XCTAssertNotNil([nyanCat.fields[@"image"] URL], @"");
        
        nyanCat.locale = @"de-DE";
        XCTAssertEqualObjects(@"Nyan Cat", nyanCat.fields[@"name"], @"");
        XCTAssertNotNil([nyanCat.fields[@"image"] URL], @"");

        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    XCTAssertNotNil(request, @"");
    
    WaitUntilBlockCompletes();
}

-(void)testNoSyncTokenAvailableError {
    StartBlock();
    
    self.client = [[CDAClient alloc] initWithSpaceKey:@"emh6o2ireilu" accessToken:@"something"];
    
    [self addDummyContentType];
    
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response,
                                                                           CDASyncedSpace *space) {
        [space performSynchronizationWithSuccess:^{
            XCTFail(@"Request should not succeed due to missing sync token.");
            
            EndBlock();
        } failure:^(CDAResponse *response, NSError *error) {
            XCTAssertEqualObjects(CDAErrorDomain, error.domain, @"");
            XCTAssertEqual(901, error.code, @"");
            XCTAssertEqualObjects(@"No sync token available.", error.localizedDescription, @"");
            
            EndBlock();
        }];
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    XCTAssertNotNil(request, @"");
    
    WaitUntilBlockCompletes();
}

-(void)testPagingWhileSyncing {
    [OHHTTPStubs removeAllStubs];
    
    StartBlock();
    
    self.client = [[CDAClient alloc] initWithSpaceKey:@"lzjz8hygvfgu" accessToken:@"0c6ef483524b5e46b3bafda1bf355f38f5f40b4830f7599f790a410860c7c271"];
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response, CDASyncedSpace *space) {
        XCTAssertEqual(594U, space.entries.count, @"");
        
        [space performSynchronizationWithSuccess:^{
            XCTAssertEqual(594U, space.entries.count, @"");
            
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

-(void)testSyncedSpaceSupportsKeyValueObservation {
    __block CDASyncedSpace* aSpace = nil;
    
    StartBlock();
    
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response,
                                                                           CDASyncedSpace *space) {
        aSpace = space;
        
        [aSpace addObserver:self forKeyPath:@"assets" options:0 context:NULL];
        [aSpace addObserver:self forKeyPath:@"entries" options:0 context:NULL];
        
        [space performSynchronizationWithSuccess:^{
            XCTAssertEqual(1U, space.assets.count, @"");
            XCTAssertEqual(2U, space.entries.count, @"");
            
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
    
    [aSpace removeObserver:self forKeyPath:@"assets" context:NULL];
    [aSpace removeObserver:self forKeyPath:@"entries" context:NULL];
    
    XCTAssertFalse(self.waiting, @"Observer hasn't fired.");
}

-(void)testSyncAddAsset {
    StartBlock();
    
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response,
                                                                           CDASyncedSpace *space) {
        space.delegate = self;
        
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
    
    XCTAssertEqual(3U, self.numberOfDelegateMethodCalls, @"");
}

-(void)testSyncRemoveAsset {
    self.expectFieldsInDeletedResources = YES;
    
    StartBlock();
    
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response,
                                                                           CDASyncedSpace *space) {
        space.delegate = self;
        
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
    
    XCTAssertEqual(4U, self.numberOfDelegateMethodCalls, @"");
}

-(void)testSyncAddEntry {
    StartBlock();
    
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response,
                                                                           CDASyncedSpace *space) {
        space.delegate = self;
        
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
    
    XCTAssertEqual(1U, self.numberOfDelegateMethodCalls, @"");
}

-(void)testSyncRemoveEntry {
    self.expectFieldsInDeletedResources = YES;
    
    StartBlock();
    
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response,
                                                                           CDASyncedSpace *space) {
        space.delegate = self;
        
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
    
    XCTAssertEqual(2U, self.numberOfDelegateMethodCalls, @"");
}

-(void)testSyncUpdate {
    StartBlock();
    
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response,
                                                                           CDASyncedSpace *space) {
        space.delegate = self;
        
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
                        
                        [space performSynchronizationWithSuccess:^{
                            XCTAssertEqual(1U, space.assets.count, @"");
                            XCTAssertEqual(1U, space.entries.count, @"");
                            
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
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    XCTAssertNotNil(request, @"");
    
    WaitUntilBlockCompletes();
    
    XCTAssertEqual(6U, self.numberOfDelegateMethodCalls, @"");
}

#pragma mark - CDASyncedSpaceDelegate

-(void)syncedSpace:(CDASyncedSpace *)space didCreateAsset:(CDAAsset *)asset {
    XCTAssert([asset isKindOfClass:[CDAAsset class]], @"");
    XCTAssertNotNil(asset.identifier, @"");
    XCTAssertNotNil(asset.fields, @"");
    
    self.numberOfDelegateMethodCalls++;
}

-(void)syncedSpace:(CDASyncedSpace *)space didCreateEntry:(CDAEntry *)entry {
    XCTAssert([entry isKindOfClass:[CDAEntry class]], @"");
    XCTAssertNotNil(entry.identifier, @"");
    XCTAssertNotNil(entry.fields, @"");
    
    self.numberOfDelegateMethodCalls++;
}

-(void)syncedSpace:(CDASyncedSpace *)space didDeleteAsset:(CDAAsset *)asset {
    XCTAssert([asset isKindOfClass:[CDAAsset class]] ||
              [asset isKindOfClass:[CDADeletedAsset class]], @"");
    XCTAssertNotNil(asset.identifier, @"");
    
    if (self.expectFieldsInDeletedResources) {
        XCTAssertNotNil(asset.fields, @"");
    }
    
    self.numberOfDelegateMethodCalls++;
}

-(void)syncedSpace:(CDASyncedSpace *)space didDeleteEntry:(CDAEntry *)entry {
    XCTAssert([entry isKindOfClass:[CDAEntry class]] ||
              [entry isKindOfClass:[CDADeletedEntry class]], @"");
    XCTAssertNotNil(entry.identifier, @"");
    
    if (self.expectFieldsInDeletedResources) {
        XCTAssertNotNil(entry.fields, @"");
    }
    
    self.numberOfDelegateMethodCalls++;
}

-(void)syncedSpace:(CDASyncedSpace *)space didUpdateAsset:(CDAAsset *)asset {
    XCTAssert([asset isKindOfClass:[CDAAsset class]], @"");
    XCTAssertNotNil(asset.identifier, @"");
    XCTAssertNotNil(asset.fields, @"");
    
    self.numberOfDelegateMethodCalls++;
}

-(void)syncedSpace:(CDASyncedSpace *)space didUpdateEntry:(CDAEntry *)entry {
    XCTAssert([entry isKindOfClass:[CDAEntry class]], @"");
    XCTAssertNotNil(entry.identifier, @"");
    XCTAssertNotNil(entry.fields, @"");
    
    self.numberOfDelegateMethodCalls++;
}

@end
