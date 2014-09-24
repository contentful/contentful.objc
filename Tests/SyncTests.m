//
//  SyncTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 25/03/14.
//
//

#import "CDAResource+Private.h"
#import "SyncBaseTestCase.h"

@interface MYCustomClass : CDAEntry

@end

#pragma mark -

@implementation MYCustomClass

@end

#pragma mark -

@interface SyncedSpaceDelegate : NSObject <CDASyncedSpaceDelegate>

@end

#pragma mark -

@implementation SyncedSpaceDelegate

@end

#pragma mark -

@interface SyncTests : SyncBaseTestCase

@property (nonatomic) NSURL* temporaryFileURL;
@property (nonatomic) BOOL waiting;

@end

#pragma mark -

@implementation SyncTests

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object change:(NSDictionary *)change
                      context:(void *)context {
    XCTAssert([keyPath isEqualToString:@"assets"] || [keyPath isEqualToString:@"entries"], @"");
    
    self.waiting = NO;
}

-(void)setUp {
    [super setUp];
    
    self.waiting = YES;
    
    NSString *fileName = [NSString stringWithFormat:@"%@_%@",
                          [[NSProcessInfo processInfo] globallyUniqueString], @"file.data"];
    self.temporaryFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory()
                                                    stringByAppendingPathComponent:fileName]];
    
    /* 
     Map URLs to JSON response files
     
     The tests are based on a sync session with five subsequent syncs where each one either added,
     removed or updated Resources.
     */
    NSDictionary* stubs = @{ @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?initial=true": @"initial", @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyYxwoHDtsKywrXDmQs_WcOvIcOzwotYw6PCgcOsAcOYYcO4YsKCw7TCnsK_clnClS7Csx9lwoFcw6nCqnnCpWh3w7k7SkI-CcOuQyXDlw_Dlh9RwqkcElwpW30sw4k": @"added", @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyY0w4bCiMKOWDIFw61bwqQ_w73CnMKsB8KpwrFZPsOZw5ZQwqDDnUA0w5tOPRtwwoAkwpJMTzghdEnDjCkiw5fCuynDlsO5DyvCsjgQa2TDisKNZ8Kqw4TCjhZIGQ": @"deleted", @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyZew5xDN04dJg3DkmBAw4XDh8OEw5o5UVhIw6nDlFjDoBxIasKIDsKIw4VcIV18GicdwoTDjCtoMiFAfcKiwrRKIsKYwrzCmMKBw4ZhwrdhwrsGa8KTwpQ6w6A": @"added-asset", @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyZ_NnHDoQzCtcKoMh9KZHtAWcObw7XCimZgVGPChUfDuxQHwoHDosO6CcKodsO2MWJQwrrCrsOswpl5w6LCuV0tw4Njwo9Ww5fCl8KqEgB6XgAJNVF2wpk3Lg": @"deleted-asset", @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyYHPUPDhggxwr5qw5RBbMKWw4VjOg3DumTDg0_CgsKcYsO8UcOZfMKLw4sKUcOnJcKxfDUkGWwxNMOVw4AiacK5Bmo4ScOhI0g2cXLClxTClsOyE8OOc8O3": @"update", @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?initial=true": @"initialWithoutToken", @"https://cdn.contentful.com/spaces/emh6o2ireilu/": @"space", @"https://cdn.contentful.com/spaces/emh6o2ireilu/": @"space", };
    
    [self stubHTTPRequestUsingFixtures:stubs inDirectory:@"SyncTests"];
}

-(void)testContinueSyncAfterPersisting {
    StartBlock();
    
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response, CDASyncedSpace *space) {
        XCTAssertEqual(1U, space.assets.count, @"");
        XCTAssertEqual(1U, space.entries.count, @"");
        [space writeToFile:self.temporaryFileURL.path];
        
        self.client = [self mockContentTypeRetrievalForClient:[self buildClient]];
        space = [CDASyncedSpace readFromFile:self.temporaryFileURL.path client:self.client];
        XCTAssertEqual(1U, space.assets.count, @"");
        XCTAssertEqual(1U, space.entries.count, @"");
        
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
}

-(void)testContinueSyncWithoutSyncSpaceInstance {
    StartBlock();
    
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response, CDASyncedSpace *space) {
        XCTAssertEqual(1U, space.assets.count, @"");
        XCTAssertEqual(1U, space.entries.count, @"");
        
        NSDate* lastSyncTimestamp = space.lastSyncTimestamp;
        NSString* syncToken = space.syncToken;
        space = nil;
        XCTAssertNil(space, @"");
        XCTAssertNotNil(lastSyncTimestamp, @"");
        XCTAssertNotEqualObjects([NSDate distantPast], lastSyncTimestamp, @"");
        
        self.client = [self mockContentTypeRetrievalForClient:[self buildClient]];
        
        CDASyncedSpace* shallowSyncSpace = [CDASyncedSpace shallowSyncSpaceWithToken:syncToken
                                                                              client:self.client];
        shallowSyncSpace.delegate = self;
        shallowSyncSpace.lastSyncTimestamp = lastSyncTimestamp;
        
        [shallowSyncSpace performSynchronizationWithSuccess:^{
            XCTAssertNil(shallowSyncSpace.assets, @"");
            XCTAssertNil(shallowSyncSpace.entries, @"");
            XCTAssertNotEqualObjects(shallowSyncSpace.lastSyncTimestamp, lastSyncTimestamp, @"");
            
            [shallowSyncSpace performSynchronizationWithSuccess:^{
                XCTAssertNil(shallowSyncSpace.assets, @"");
                XCTAssertNil(shallowSyncSpace.entries, @"");
                XCTAssertNotEqualObjects(shallowSyncSpace.lastSyncTimestamp, lastSyncTimestamp, @"");
                
                [shallowSyncSpace performSynchronizationWithSuccess:^{
                    XCTAssertNil(shallowSyncSpace.assets, @"");
                    XCTAssertNil(shallowSyncSpace.entries, @"");
                    XCTAssertNotEqualObjects(shallowSyncSpace.lastSyncTimestamp, lastSyncTimestamp, @"");
                    
                    [shallowSyncSpace performSynchronizationWithSuccess:^{
                        XCTAssertNil(shallowSyncSpace.assets, @"");
                        XCTAssertNil(shallowSyncSpace.entries, @"");
                        XCTAssertNotEqualObjects(shallowSyncSpace.lastSyncTimestamp,
                                                 lastSyncTimestamp, @"");
                        
                        [shallowSyncSpace performSynchronizationWithSuccess:^{
                            XCTAssertNil(shallowSyncSpace.assets, @"");
                            XCTAssertNil(shallowSyncSpace.entries, @"");
                            XCTAssertNotEqualObjects(shallowSyncSpace.lastSyncTimestamp,
                                                     lastSyncTimestamp, @"");
                            
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
    
    XCTAssertEqual(1U, self.numberOfAssetsCreated, @"");
    XCTAssertEqual(1U, self.numberOfAssetsDeleted, @"");
    XCTAssertEqual(1U, self.numberOfAssetsUpdated, @"");
    XCTAssertEqual(1U, self.numberOfEntriesCreated, @"");
    XCTAssertEqual(1U, self.numberOfEntriesDeleted, @"");
    XCTAssertEqual(1U, self.numberOfEntriesUpdated, @"");
    XCTAssert(self.contentTypesWereFetched, @"Content Types were not fetched.");
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
    
    XCTAssertEqual(0U, self.numberOfAssetsCreated, @"");
    XCTAssertEqual(0U, self.numberOfAssetsDeleted, @"");
    XCTAssertEqual(0U, self.numberOfAssetsUpdated, @"");
    XCTAssertEqual(0U, self.numberOfEntriesCreated, @"");
    XCTAssertEqual(0U, self.numberOfEntriesDeleted, @"");
    XCTAssertEqual(0U, self.numberOfEntriesUpdated, @"");
}

-(void)testSyncWithNonUSDefaultLocale {
    [self removeAllStubs];
    self.client = [[CDAClient alloc] initWithSpaceKey:@"icgl406qq59m" accessToken:@"77a3cc4cfaef46d2d93d7924f571d45392a4abb998c1d17d301bc7dc62f3dfd4"];
    
    StartBlock();
    
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response, CDASyncedSpace *space) {
        XCTAssertEqual(0UL, space.assets.count, @"");
        XCTAssertEqual(1UL, space.entries.count, @"");
        
        CDAEntry* entry = space.entries.firstObject;
        XCTAssertEqualObjects(@"My first entry", entry.fields[@"title"], @"");
        XCTAssertEqualObjects(@"Hello, world!", entry.fields[@"body"], @"");
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    XCTAssertNotNil(request, @"");
    
    WaitUntilBlockCompletes();
    
    XCTAssertEqual(0U, self.numberOfAssetsCreated, @"");
    XCTAssertEqual(0U, self.numberOfAssetsDeleted, @"");
    XCTAssertEqual(0U, self.numberOfAssetsUpdated, @"");
    XCTAssertEqual(0U, self.numberOfEntriesCreated, @"");
    XCTAssertEqual(0U, self.numberOfEntriesDeleted, @"");
    XCTAssertEqual(0U, self.numberOfEntriesUpdated, @"");
}

-(void)testAssetWithMultipleLocalesWhileSyncing {
    [self removeAllStubs];
    
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
    [self removeAllStubs];
    
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
    [self removeAllStubs];
    
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

                    NSArray* assets = [space.assets sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES] ]];
                    CDAAsset* asset = [assets lastObject];
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
    
    XCTAssertEqual(1U, self.numberOfAssetsCreated, @"");
    XCTAssertEqual(1U, self.numberOfEntriesCreated, @"");
    XCTAssertEqual(1U, self.numberOfEntriesDeleted, @"");
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
    
    XCTAssertEqual(1U, self.numberOfAssetsCreated, @"");
    XCTAssertEqual(1U, self.numberOfAssetsDeleted, @"");
    XCTAssertEqual(1U, self.numberOfEntriesCreated, @"");
    XCTAssertEqual(1U, self.numberOfEntriesDeleted, @"");
}

-(void)testSyncAddEntry {
    StartBlock();
    
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response,
                                                                           CDASyncedSpace *space) {
        space.delegate = self;
        
        [space performSynchronizationWithSuccess:^{
            XCTAssertEqual(1U, space.assets.count, @"");
            XCTAssertEqual(2U, space.entries.count, @"");
            
            BOOL entryFound = NO;
            
            for (CDAEntry* entry in space.entries) {
                if ([entry.identifier isEqualToString:@"1gQ4P2tG7QaGkQwkC4a6Gg"]) {
                    XCTAssertEqualObjects(@"Second entry", entry.fields[@"title"], @"");
                    XCTAssertEqualObjects(@"some text", entry.fields[@"body"], @"");
                    entryFound = YES;
                }
            }
            
            XCTAssert(entryFound, @"Second entry not found.");
            
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
    
    XCTAssertEqual(1U, self.numberOfEntriesCreated, @"");
}

-(void)testSyncAddEntryUsingCustomClass {
    [self.client registerClass:[MYCustomClass class] forContentTypeWithIdentifier:@"6bAvxqodl6s4MoKuWYkmqe"];
    
    StartBlock();
    
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response, CDASyncedSpace *space) {
        space.delegate = self;
        
        [space performSynchronizationWithSuccess:^{
            XCTAssertEqual(1U, space.assets.count, @"");
            XCTAssertEqual(2U, space.entries.count, @"");
            
            BOOL entryFound = NO;
            
            for (CDAEntry* entry in space.entries) {
                if ([entry.identifier isEqualToString:@"1gQ4P2tG7QaGkQwkC4a6Gg"]) {
                    XCTAssertEqualObjects(@"Second entry", entry.fields[@"title"], @"");
                    XCTAssertEqualObjects(@"some text", entry.fields[@"body"], @"");
                    entryFound = YES;
                }
            }
            
            XCTAssert(entryFound, @"Second entry not found.");
            
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
    
    XCTAssertEqual(1U, self.numberOfEntriesCreated, @"");
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
    
    XCTAssertEqual(1U, self.numberOfEntriesCreated, @"");
    XCTAssertEqual(1U, self.numberOfEntriesDeleted, @"");
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
    
    XCTAssertEqual(1U, self.numberOfAssetsCreated, @"");
    XCTAssertEqual(1U, self.numberOfAssetsDeleted, @"");
    XCTAssertEqual(1U, self.numberOfAssetsUpdated, @"");
    XCTAssertEqual(1U, self.numberOfEntriesCreated, @"");
    XCTAssertEqual(1U, self.numberOfEntriesDeleted, @"");
    XCTAssertEqual(1U, self.numberOfEntriesUpdated, @"");
}

@end
