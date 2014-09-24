//
//  CoreDataBasicTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 15/04/14.
//
//

#import "CoreDataBaseTestCase.h"

@interface CoreDataBasicTests : CoreDataBaseTestCase

@end

#pragma mark -

@implementation CoreDataBasicTests

-(void)setUp {
    [super setUp];
    
    /*
     Map URLs to JSON response files
     
     The tests are based on a sync session with five subsequent syncs where each one either added,
     removed or updated Resources.
     */
    NSDictionary* stubs = @{ @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?initial=true": @"initial", @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyYxwoHDtsKywrXDmQs_WcOvIcOzwotYw6PCgcOsAcOYYcO4YsKCw7TCnsK_clnClS7Csx9lwoFcw6nCqnnCpWh3w7k7SkI-CcOuQyXDlw_Dlh9RwqkcElwpW30sw4k": @"added", @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyY0w4bCiMKOWDIFw61bwqQ_w73CnMKsB8KpwrFZPsOZw5ZQwqDDnUA0w5tOPRtwwoAkwpJMTzghdEnDjCkiw5fCuynDlsO5DyvCsjgQa2TDisKNZ8Kqw4TCjhZIGQ": @"deleted", @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyZew5xDN04dJg3DkmBAw4XDh8OEw5o5UVhIw6nDlFjDoBxIasKIDsKIw4VcIV18GicdwoTDjCtoMiFAfcKiwrRKIsKYwrzCmMKBw4ZhwrdhwrsGa8KTwpQ6w6A": @"added-asset", @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyZ_NnHDoQzCtcKoMh9KZHtAWcObw7XCimZgVGPChUfDuxQHwoHDosO6CcKodsO2MWJQwrrCrsOswpl5w6LCuV0tw4Njwo9Ww5fCl8KqEgB6XgAJNVF2wpk3Lg": @"deleted-asset", @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyYHPUPDhggxwr5qw5RBbMKWw4VjOg3DumTDg0_CgsKcYsO8UcOZfMKLw4sKUcOnJcKxfDUkGWwxNMOVw4AiacK5Bmo4ScOhI0g2cXLClxTClsOyE8OOc8O3": @"update", @"https://cdn.contentful.com/spaces/emh6o2ireilu/": @"space", @"https://cdn.contentful.com/spaces/giq5kda3eap4/sync?initial=true": @"932-initial", @"https://cdn.contentful.com/spaces/giq5kda3eap4/": @"932-space", @"https://cdn.contentful.com/spaces/giq5kda3eap4/content_types?limit=1&sys.id%5Bin%5D=1nGOrvlRTaMcyyq4IEa8ea": @"932-content-types", @"https://cdn.contentful.com/spaces/giq5kda3eap4/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdybDqiDCvSIrAFoiw7XDkQrCu8K7N8OkwqlhwoHCscOLM8Knwr7Cp8Ogw7LCjE3DicO8w6cCwoFwO1AVw6B8DGTCtlbDgMKDw7zDicKawrXDqsKkSX7DnMO-ThjDtMORwqHDhk_Ct1o": @"932-add-entry", @"https://cdn.contentful.com/spaces/giq5kda3eap4/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyY5dsK6w79SE2ADw41bNA58M8KLw5ZzWcKMw5Q-w4Nxw6UzCSTCtQPCrcK5w63CmcKtwq9IwqM6V8OrCsKow6LCisO9K8KfSiEKw5PCnVZQBQfCrsOiwoweCcK0wpvDoQ": @"932-unpublish-entry", @"https://cdn.contentful.com/spaces/giq5kda3eap4/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdybCqx_CocOlwpNuw41raMKrw7nCv8OAwrnCihwDwqnCmUbCjhnDmTojwrZAw7vDuMKCH8Kcw6USTMOqw4NAwo7Cn8KUaVYXwrHCkVLCmsOgNxs-wptWw5LDl8KIw4vCvsOTwq7CsnJJ": @"932-republish-entry" };
    
    [self stubHTTPRequestUsingFixtures:stubs inDirectory:@"SyncTests"];
}

#pragma mark -

-(void)testContinueSyncFromDataStore {
    StartBlock();
    
    [self.coreDataManager performSynchronizationWithSuccess:^{
        [self assertNumberOfAssets:1U numberOfEntries:1U];
        [self buildCoreDataManagerWithDefaultClient:NO];
        
        Asset* asset = [[self.coreDataManager fetchAssetsFromDataStore] firstObject];
        XCTAssertEqualObjects(@"512_black.png", asset.url.lastPathComponent, @"");
        ManagedCat* cat = [[self.coreDataManager fetchEntriesFromDataStore] firstObject];
        XCTAssertEqualObjects(@"Test", cat.name, @"");
        
        [self.coreDataManager performSynchronizationWithSuccess:^{
            [self assertNumberOfAssets:1U numberOfEntries:2U];
            [self buildCoreDataManagerWithDefaultClient:NO];
            
            [self.coreDataManager performSynchronizationWithSuccess:^{
                [self assertNumberOfAssets:1U numberOfEntries:1U];
                [self buildCoreDataManagerWithDefaultClient:NO];
                
                [self.coreDataManager performSynchronizationWithSuccess:^{
                    [self assertNumberOfAssets:2U numberOfEntries:1U];
                    [self buildCoreDataManagerWithDefaultClient:NO];
                    
                    [self.coreDataManager performSynchronizationWithSuccess:^{
                        [self assertNumberOfAssets:1U numberOfEntries:1U];
                        [self buildCoreDataManagerWithDefaultClient:NO];
                        
                        [self.coreDataManager performSynchronizationWithSuccess:^{
                            [self assertNumberOfAssets:1U numberOfEntries:1U];
                            
                            Asset* asset = [[self.coreDataManager fetchAssetsFromDataStore] firstObject];
                            XCTAssertEqualObjects(@"vaa4by0.png", asset.url.lastPathComponent, @"");
                            ManagedCat* cat = [[self.coreDataManager fetchEntriesFromDataStore] firstObject];
                            XCTAssertEqualObjects(@"Test (changed)", cat.name, @"");
                            
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
    
    WaitUntilBlockCompletes();
}

-(void)testContinueSyncWithSameManager {
    StartBlock();
    
    [self.coreDataManager performSynchronizationWithSuccess:^{
        [self assertNumberOfAssets:1U numberOfEntries:1U];
        
        Asset* asset = [[self.coreDataManager fetchAssetsFromDataStore] firstObject];
        XCTAssertEqualObjects(@"512_black.png", asset.url.lastPathComponent, @"");
        ManagedCat* cat = [[self.coreDataManager fetchEntriesFromDataStore] firstObject];
        XCTAssertEqualObjects(@"Test", cat.name, @"");
        
        [self.coreDataManager performSynchronizationWithSuccess:^{
            [self assertNumberOfAssets:1U numberOfEntries:2U];
            
            [self.coreDataManager performSynchronizationWithSuccess:^{
                [self assertNumberOfAssets:1U numberOfEntries:1U];
                
                [self.coreDataManager performSynchronizationWithSuccess:^{
                    [self assertNumberOfAssets:2U numberOfEntries:1U];
                    
                    [self.coreDataManager performSynchronizationWithSuccess:^{
                        [self assertNumberOfAssets:1U numberOfEntries:1U];
                        
                        [self.coreDataManager performSynchronizationWithSuccess:^{
                            [self assertNumberOfAssets:1U numberOfEntries:1U];
                            
                            Asset* asset = [[self.coreDataManager fetchAssetsFromDataStore] firstObject];
                            XCTAssertEqualObjects(@"vaa4by0.png", asset.url.lastPathComponent, @"");
                            ManagedCat* cat = [[self.coreDataManager fetchEntriesFromDataStore] firstObject];
                            XCTAssertEqualObjects(@"Test (changed)", cat.name, @"");
                            
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
    
    WaitUntilBlockCompletes();
}

-(void)testInitialSync {
    [self removeAllStubs];
    [self buildCoreDataManagerWithDefaultClient:YES];
    
    StartBlock();
    
    [self.coreDataManager performSynchronizationWithSuccess:^{
        XCTAssertEqual(4U, [self.coreDataManager fetchAssetsFromDataStore].count, @"");
        XCTAssertEqual(3U, [self.coreDataManager fetchEntriesFromDataStore].count, @"");
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

-(void)testMappingOfFields {
    [self removeAllStubs];
    [self buildCoreDataManagerWithDefaultClient:YES];
    
    StartBlock();
    
    [self.coreDataManager performSynchronizationWithSuccess:^{
        for (ManagedCat* cat in [self.coreDataManager fetchEntriesOfContentTypeWithIdentifier:@"cat"
                                                                            matchingPredicate:nil]) {
            XCTAssertNotNil(cat.color, @"");
            XCTAssertNotNil(cat.name, @"");
            XCTAssert([cat.livesLeft intValue] > 0, @"");
        }
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

-(void)testRelationships {
    [self removeAllStubs];
    [self buildCoreDataManagerWithDefaultClient:YES];
    
    StartBlock();
    
    [self.coreDataManager performSynchronizationWithSuccess:^{
        [self buildCoreDataManagerWithDefaultClient:YES];
        
        XCTAssertEqual(4U, [self.coreDataManager fetchAssetsFromDataStore].count, @"");
        XCTAssertEqual(3U, [self.coreDataManager fetchEntriesFromDataStore].count, @"");
        
        ManagedCat* nyanCat = [self.coreDataManager fetchEntryWithIdentifier:@"nyancat"];
        XCTAssertNotNil(nyanCat, @"");
        XCTAssertNotNil(nyanCat.picture, @"");
        XCTAssertNotNil(nyanCat.picture.url, @"");
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

-(void)testSyncWithRepublishedEntry {
    self.client = [[CDAClient alloc] initWithSpaceKey:@"giq5kda3eap4" accessToken:@"9823965a99805cf9bd6f091b2faf6eef652eff12ae0c79acacd370f873bc6fe0"];
    [self buildCoreDataManagerWithDefaultClient:NO];
    
    StartBlock();
    
    [self.coreDataManager performSynchronizationWithSuccess:^{
        XCTAssertEqual(1U, [self.coreDataManager fetchEntriesFromDataStore].count, @"");
        
        [self buildCoreDataManagerWithDefaultClient:NO];
        [self.coreDataManager performSynchronizationWithSuccess:^{
            XCTAssertEqual(2U, [self.coreDataManager fetchEntriesFromDataStore].count, @"");
            
            [self buildCoreDataManagerWithDefaultClient:NO];
            [self.coreDataManager performSynchronizationWithSuccess:^{
                XCTAssertEqual(1U, [self.coreDataManager fetchEntriesFromDataStore].count, @"");
                
                [self buildCoreDataManagerWithDefaultClient:NO];
                [self.coreDataManager performSynchronizationWithSuccess:^{
                    XCTAssertEqual(2U, [self.coreDataManager fetchEntriesFromDataStore].count, @"");
                    
                    [self buildCoreDataManagerWithDefaultClient:NO];
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
    
    WaitUntilBlockCompletes();
}

-(void)testImageCaching {
    [self removeAllStubs];
    [self buildCoreDataManagerWithDefaultClient:YES];

    StartBlock();

    [self.coreDataManager performSynchronizationWithSuccess:^{
        __block id<CDAPersistedAsset> asset = [[[self.coreDataManager fetchAssetsFromDataStore] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier == 'nyancat'"]] firstObject];
        XCTAssertNotNil(asset, @"");

        [CDAAsset cachePersistedAsset:asset
                               client:self.coreDataManager.client
                     forcingOverwrite:YES
                    completionHandler:^(BOOL success) {
                        NSURLRequest* assetRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:asset.url]];
                        [NSURLConnection sendAsynchronousRequest:assetRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                            XCTAssertNotNil(data, @"Error: %@", connectionError);

                            [self buildCoreDataManagerWithDefaultClient:YES];
                            CDAClient* client = [self.coreDataManager client];
                            asset = [[[self.coreDataManager fetchAssetsFromDataStore] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier == 'nyancat'"]] firstObject];

                            NSData* cachedData = [CDAAsset cachedDataForPersistedAsset:asset
                                                                                client:client];
                            UIImage* cachedImage = [UIImage imageWithData:cachedData];
                            XCTAssertNotNil(cachedImage, @"");
                            XCTAssertEqual(asset.width.floatValue, cachedImage.size.width, @"");
                            XCTAssertEqual(asset.height.floatValue, cachedImage.size.height, @"");

                            UIImage* refImage = [UIImage imageWithData:data];
                            NSError* error;
                            BOOL result = [self.snapshotTestController compareReferenceImage:refImage
                                                                                     toImage:cachedImage
                                                                                       error:&error];
                            XCTAssertTrue(result, @"Error: %@", error);

                            EndBlock();
                        }];
                    }];
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);

        EndBlock();
    }];

    WaitUntilBlockCompletes();
}

// FIXME: Deactivated right now as it fails on Travis
#if 0
-(void)testUseExistingDatabase {
    NSURL* documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL* toURL = [documentsDirectory URLByAppendingPathComponent:@"CoreDataExample.sqlite"];
    
    NSError* error;
    BOOL result = [[NSFileManager defaultManager] copyItemAtURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"CoreDataExample" withExtension:@"sqlite" subdirectory:@"Fixtures"]
                                                          toURL:toURL
                                                          error:&error];
    XCTAssert(result, @"Error: %@", error);
    
    [self buildCoreDataManagerWithDefaultClient:YES];
    XCTAssertEqual(4U, [self.coreDataManager fetchAssetsFromDataStore].count, @"");
    XCTAssertEqual(10U, [self.coreDataManager fetchEntriesFromDataStore].count, @"");
    
    [[NSFileManager defaultManager] removeItemAtURL:toURL error:nil];
}
#endif

@end
