//
//  PersistenceBaseTest+Basic.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 08/12/14.
//
//

#import "PersistenceBaseTest+Basic.h"

@implementation PersistenceBaseTest (Basic)

-(void)basic_setupFixtures {
    /*
     Map URLs to JSON response files

     The tests are based on a sync session with five subsequent syncs where each one either added,
     removed or updated Resources.
     */
    NSDictionary* stubs = @{ @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?initial=true": @"initial",
                             @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyYxwoHDtsKywrXDmQs_WcOvIcOzwotYw6PCgcOsAcOYYcO4YsKCw7TCnsK_clnClS7Csx9lwoFcw6nCqnnCpWh3w7k7SkI-CcOuQyXDlw_Dlh9RwqkcElwpW30sw4k": @"added",
                             @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyY0w4bCiMKOWDIFw61bwqQ_w73CnMKsB8KpwrFZPsOZw5ZQwqDDnUA0w5tOPRtwwoAkwpJMTzghdEnDjCkiw5fCuynDlsO5DyvCsjgQa2TDisKNZ8Kqw4TCjhZIGQ": @"deleted",
                             @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyZew5xDN04dJg3DkmBAw4XDh8OEw5o5UVhIw6nDlFjDoBxIasKIDsKIw4VcIV18GicdwoTDjCtoMiFAfcKiwrRKIsKYwrzCmMKBw4ZhwrdhwrsGa8KTwpQ6w6A": @"added-asset", @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyZ_NnHDoQzCtcKoMh9KZHtAWcObw7XCimZgVGPChUfDuxQHwoHDosO6CcKodsO2MWJQwrrCrsOswpl5w6LCuV0tw4Njwo9Ww5fCl8KqEgB6XgAJNVF2wpk3Lg": @"deleted-asset",
                             @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyYHPUPDhggxwr5qw5RBbMKWw4VjOg3DumTDg0_CgsKcYsO8UcOZfMKLw4sKUcOnJcKxfDUkGWwxNMOVw4AiacK5Bmo4ScOhI0g2cXLClxTClsOyE8OOc8O3": @"update",
                             @"https://cdn.contentful.com/spaces/emh6o2ireilu/": @"space", @"https://cdn.contentful.com/spaces/emh6o2ireilu/content_types": @"all-content-types", @"https://cdn.contentful.com/spaces/giq5kda3eap4/sync?initial=true": @"932-initial",
                             @"https://cdn.contentful.com/spaces/giq5kda3eap4/": @"932-space",
                             @"https://cdn.contentful.com/spaces/giq5kda3eap4/content_types?limit=1&sys.id%5Bin%5D=1nGOrvlRTaMcyyq4IEa8ea": @"932-content-types",
                             @"https://cdn.contentful.com/spaces/giq5kda3eap4/": @"932-space",
                             @"https://cdn.contentful.com/spaces/giq5kda3eap4/content_types": @"932-all-content-types",
                             @"https://cdn.contentful.com/spaces/giq5kda3eap4/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdybDqiDCvSIrAFoiw7XDkQrCu8K7N8OkwqlhwoHCscOLM8Knwr7Cp8Ogw7LCjE3DicO8w6cCwoFwO1AVw6B8DGTCtlbDgMKDw7zDicKawrXDqsKkSX7DnMO-ThjDtMORwqHDhk_Ct1o": @"932-add-entry",
                             @"https://cdn.contentful.com/spaces/giq5kda3eap4/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyY5dsK6w79SE2ADw41bNA58M8KLw5ZzWcKMw5Q-w4Nxw6UzCSTCtQPCrcK5w63CmcKtwq9IwqM6V8OrCsKow6LCisO9K8KfSiEKw5PCnVZQBQfCrsOiwoweCcK0wpvDoQ": @"932-unpublish-entry",
                             @"https://cdn.contentful.com/spaces/giq5kda3eap4/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdybCqx_CocOlwpNuw41raMKrw7nCv8OAwrnCihwDwqnCmUbCjhnDmTojwrZAw7vDuMKCH8Kcw6USTMOqw4NAwo7Cn8KUaVYXwrHCkVLCmsOgNxs-wptWw5LDl8KIw4vCvsOTwq7CsnJJ": @"932-republish-entry",
                             @"https://cdn.contentful.com/spaces/a7uc4j82xa5d/sync?initial=true": @"initial-for-empty",
                             @"https://cdn.contentful.com/spaces/a7uc4j82xa5d/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyY9ZMK9AsOcwqzCqmEWwr7CucOhw7LCm8ONZQICw4PCo8Olwq0lwofCocO2C3rDmAM_wr_DuMOcDBVGwqnCpcOBXsKXw6M9J8O4w4EUw7Zww6TCtsKwOzfCucOpVkLDtWXCsMOydg": @"update-for-empty",
                             @"https://cdn.contentful.com/spaces/a7uc4j82xa5d/": @"space-for-empty",
                             @"https://cdn.contentful.com/spaces/a7uc4j82xa5d/content_types": @"content-types-for-empty"
                            };

    [self stubHTTPRequestUsingFixtures:stubs inDirectory:@"SyncTests"];
}

-(void)basic_continueSyncFromDataStore {
    StartBlock();

    [self.persistenceManager performSynchronizationWithSuccess:^{
        [self assertNumberOfAssets:1U numberOfEntries:1U];
        [self buildPersistenceManagerWithDefaultClient:NO];

        [self.persistenceManager performBlock:^{ // Since we are switching managers here
        id<CDAPersistedAsset> asset = [[self.persistenceManager fetchAssetsFromDataStore] firstObject];
        XCTAssertEqualObjects(@"512_black.png", asset.url.lastPathComponent, @"");
        id cat = [[self.persistenceManager fetchEntriesFromDataStore] firstObject];
        XCTAssertEqualObjects(@"Test", [cat name], @"");

        [self.persistenceManager performSynchronizationWithSuccess:^{
            [self assertNumberOfAssets:1U numberOfEntries:2U];
            [self buildPersistenceManagerWithDefaultClient:NO];

            [self.persistenceManager performSynchronizationWithSuccess:^{
                [self assertNumberOfAssets:1U numberOfEntries:1U];
                [self buildPersistenceManagerWithDefaultClient:NO];

                [self.persistenceManager performSynchronizationWithSuccess:^{
                    [self assertNumberOfAssets:2U numberOfEntries:1U];
                    [self buildPersistenceManagerWithDefaultClient:NO];

                    [self.persistenceManager performSynchronizationWithSuccess:^{
                        [self assertNumberOfAssets:1U numberOfEntries:1U];
                        [self buildPersistenceManagerWithDefaultClient:NO];

                        [self.persistenceManager performSynchronizationWithSuccess:^{
                            [self assertNumberOfAssets:1U numberOfEntries:1U];

                            id<CDAPersistedAsset> asset = [[self.persistenceManager fetchAssetsFromDataStore] firstObject];
                            XCTAssertEqualObjects(@"vaa4by0.png", asset.url.lastPathComponent, @"");
                            id cat = [[self.persistenceManager fetchEntriesFromDataStore] firstObject];
                            XCTAssertEqualObjects(@"Test (changed)", [cat name], @"");

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
        }]; }];
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);

        EndBlock();
    }];

    WaitUntilBlockCompletes();
}

-(void)basic_continueSyncWithSameManager {
    StartBlock();

    [self.persistenceManager performSynchronizationWithSuccess:^{
        [self assertNumberOfAssets:1U numberOfEntries:1U];

        id<CDAPersistedAsset> asset = [[self.persistenceManager fetchAssetsFromDataStore] firstObject];
        XCTAssertEqualObjects(@"512_black.png", asset.url.lastPathComponent, @"");
        id cat = [[self.persistenceManager fetchEntriesFromDataStore] firstObject];
        XCTAssertEqualObjects(@"Test", [cat name], @"");

        [self.persistenceManager performSynchronizationWithSuccess:^{
            [self assertNumberOfAssets:1U numberOfEntries:2U];

            [self.persistenceManager performSynchronizationWithSuccess:^{
                [self assertNumberOfAssets:1U numberOfEntries:1U];

                [self.persistenceManager performSynchronizationWithSuccess:^{
                    [self assertNumberOfAssets:2U numberOfEntries:1U];

                    [self.persistenceManager performSynchronizationWithSuccess:^{
                        [self assertNumberOfAssets:1U numberOfEntries:1U];

                        [self.persistenceManager performSynchronizationWithSuccess:^{
                            [self assertNumberOfAssets:1U numberOfEntries:1U];

                            id<CDAPersistedAsset> asset = [[self.persistenceManager fetchAssetsFromDataStore] firstObject];
                            XCTAssertEqualObjects(@"vaa4by0.png", asset.url.lastPathComponent, @"");
                            id cat = [[self.persistenceManager fetchEntriesFromDataStore] firstObject];
                            XCTAssertEqualObjects(@"Test (changed)", [cat name], @"");

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

-(void)basic_hasChanged {
    StartBlock();

    [self.persistenceManager performSynchronizationWithSuccess:^{
        XCTAssertFalse(self.persistenceManager.hasChanged);

        [self.persistenceManager performSynchronizationWithSuccess:^{
            XCTAssertTrue(self.persistenceManager.hasChanged);

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

-(void)basic_initialSync {
    [self removeAllStubs];
    [self buildPersistenceManagerWithDefaultClient:YES];

    StartBlock();

    [self.persistenceManager performSynchronizationWithSuccess:^{
        XCTAssertEqual(4U, [self.persistenceManager fetchAssetsFromDataStore].count, @"");
        XCTAssertEqual(3U, [self.persistenceManager fetchEntriesFromDataStore].count, @"");

        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);

        EndBlock();
    }];

    WaitUntilBlockCompletes();
}

-(void)basic_relationships {
    [self removeAllStubs];
    [self buildPersistenceManagerWithDefaultClient:YES];

    StartBlock();

    [self.persistenceManager performSynchronizationWithSuccess:^{
        [self buildPersistenceManagerWithDefaultClient:YES];

        [self.persistenceManager performBlock:^{ // we are using a different manager here
            XCTAssertEqual(4U, [self.persistenceManager fetchAssetsFromDataStore].count, @"");
            XCTAssertEqual(3U, [self.persistenceManager fetchEntriesFromDataStore].count, @"");

            id nyanCat = [self.persistenceManager fetchEntryWithIdentifier:@"nyancat"];
            XCTAssertNotNil(nyanCat, @"");
            XCTAssertNotNil([nyanCat picture], @"");
            XCTAssertNotNil([nyanCat picture].url, @"");
            
            EndBlock();
        }];
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);

        EndBlock();
    }];

    WaitUntilBlockCompletes();
}

-(void)basic_syncWithRepublishedEntries {
    self.client = [[CDAClient alloc] initWithSpaceKey:@"giq5kda3eap4" accessToken:@"9823965a99805cf9bd6f091b2faf6eef652eff12ae0c79acacd370f873bc6fe0"];
    [self buildPersistenceManagerWithDefaultClient:NO];

    StartBlock();

    [self.persistenceManager performSynchronizationWithSuccess:^{
        XCTAssertEqual(1U, [self.persistenceManager fetchEntriesFromDataStore].count, @"");

        [self buildPersistenceManagerWithDefaultClient:NO];
        [self.persistenceManager performSynchronizationWithSuccess:^{
            XCTAssertEqual(2U, [self.persistenceManager fetchEntriesFromDataStore].count, @"");

            [self buildPersistenceManagerWithDefaultClient:NO];
            [self.persistenceManager performSynchronizationWithSuccess:^{
                XCTAssertEqual(1U, [self.persistenceManager fetchEntriesFromDataStore].count, @"");

                [self buildPersistenceManagerWithDefaultClient:NO];
                [self.persistenceManager performSynchronizationWithSuccess:^{
                    XCTAssertEqual(2U, [self.persistenceManager fetchEntriesFromDataStore].count, @"");

                    [self buildPersistenceManagerWithDefaultClient:NO];
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

-(void)assertCachedImageWithData:(NSData*)data {
    id<CDAPersistedAsset> asset = [[[self.persistenceManager fetchAssetsFromDataStore] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier == 'nyancat'"]] firstObject];
    
    CDAClient* client = [self.persistenceManager client];
    XCTAssertNotNil(client, @"");
    NSData* cachedData = [CDAAsset cachedDataForPersistedAsset:asset client:client];

    UIImage* cachedImage = [UIImage imageWithData:cachedData];
    XCTAssertNotNil(cachedImage, @"");
    XCTAssertEqualObjects(asset.title, @"Nyan Cat");
    XCTAssertEqual(asset.width.floatValue, cachedImage.size.width, @"");
    XCTAssertEqual(asset.height.floatValue, cachedImage.size.height, @"");
    // FIXME: 
//
//    UIImage* refImage = [UIImage imageWithData:data];
//    NSError* error;
//    BOOL result = [self.snapshotTestController compareReferenceImage:refImage
//                                                             toImage:cachedImage
//                                                               error:&error];
//    XCTAssertTrue(result, @"Error: %@", error);
}

-(void)basic_imageCaching {
    [self removeAllStubs];
    [self buildPersistenceManagerWithDefaultClient:YES];

    StartBlock();

    [self.persistenceManager performSynchronizationWithSuccess:^{
        __block id<CDAPersistedAsset> asset = [[[self.persistenceManager fetchAssetsFromDataStore] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier == 'nyancat'"]] firstObject];
        XCTAssertNotNil(asset, @"");
        NSString* url = asset.url;

        [CDAAsset cachePersistedAsset:asset
                               client:self.persistenceManager.client
                     forcingOverwrite:YES
                    completionHandler:^(BOOL success) {
                        NSURLRequest* assetRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
                        [NSURLConnection sendAsynchronousRequest:assetRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                            XCTAssertNotNil(data, @"Error: %@", connectionError);

                            [self buildPersistenceManagerWithDefaultClient:YES];
                            [self.persistenceManager performBlock:^{ // we are on another context here
                                [self assertCachedImageWithData:data];

                                EndBlock();
                            }];
                        }];
                    }];
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

-(void)basic_syncEmptyField {
    self.client = [[CDAClient alloc] initWithSpaceKey:@"a7uc4j82xa5d" accessToken:@"966a679442707ea882caec4592bf3058e188a35b9bfcf1968a870cfc5e5441d5"];
     [self buildPersistenceManagerWithDefaultClient:NO];

    [self.persistenceManager setMapping:@{ @"fields.test": @"name" } forEntriesOfContentTypeWithIdentifier:@"test"];

    StartBlock();

    [self.persistenceManager performSynchronizationWithSuccess:^{
        NSArray* entries = [self.persistenceManager fetchEntriesFromDataStore];
        XCTAssertEqual(1U, entries.count, @"");
        id entry = [entries firstObject];
        XCTAssertEqualObjects(@"yolo", [entry valueForKey:@"name"]);

        [self.persistenceManager performSynchronizationWithSuccess:^{
            NSArray* entries = [self.persistenceManager fetchEntriesFromDataStore];
            XCTAssertEqual(1U, entries.count, @"");
            id updatedEntry = [entries firstObject];
            XCTAssertNotNil(updatedEntry);
            XCTAssertNil([updatedEntry valueForKey:@"name"]);

            EndBlock();
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);

            EndBlock();
        }];

        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);

        EndBlock();
    }];

    WaitUntilBlockCompletes();
}

@end
