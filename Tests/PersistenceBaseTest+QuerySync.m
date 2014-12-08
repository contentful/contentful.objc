//
//  PersistenceBaseTest+QuerySync.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 08/12/14.
//
//

#import "PersistenceBaseTest+QuerySync.h"

@implementation PersistenceBaseTest (QuerySync)

-(void)querySync_addEntry {
    [self querySync_stubInitialRequestWithJSONNamed:@"initial" updateWithJSONNamed:@"add-entry"];

    StartBlock();

    [self.persistenceManager performSynchronizationWithSuccess:^{
        [self assertNumberOfAssets:1 numberOfEntries:2];

        [self.persistenceManager performSynchronizationWithSuccess:^{
            [self assertNumberOfAssets:2 numberOfEntries:3];

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

-(void)querySync_deleteEntry {
    [self querySync_stubInitialRequestWithJSONNamed:@"initial" updateWithJSONNamed:@"delete-entry"];

    [self addRecordingWithJSONNamed:@"deletions-sync"
                        inDirectory:@"QuerySync"
                            matcher:^BOOL(NSURLRequest *request) {
                                return [request.URL.absoluteString rangeOfString:@"sync_token"].location != NSNotFound;
                            }];

    StartBlock();

    [self.persistenceManager performSynchronizationWithSuccess:^{
        [self assertNumberOfAssets:1 numberOfEntries:2];

        [self.persistenceManager performSynchronizationWithSuccess:^{
            [self assertNumberOfAssets:1 numberOfEntries:1];

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

-(void)querySync_initial {
    StartBlock();

    [self.persistenceManager performSynchronizationWithSuccess:^{
        [self assertNumberOfAssets:1 numberOfEntries:2];

        for (id entry in [self.persistenceManager fetchEntriesFromDataStore]) {
            XCTAssertNotNil([entry picture], @"");
            XCTAssertNotNil([entry picture].url, @"");
        }

        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);

        EndBlock();
    }];

    WaitUntilBlockCompletes();
}

-(void)querySync_setupClient {
    self.client = [[CDAClient alloc] initWithSpaceKey:@"6mhvnnmyn9e1" accessToken:@"c054f8439246817a657ba7c5fa99989fa50db48c4893572d9537335b0c9b153e"];
    self.query = @{ @"content_type": @"6PnRGY1dxSUmaQ2Yq2Ege2" };
}

-(void)querySync_stubInitialRequestWithJSONNamed:(NSString*)initial updateWithJSONNamed:(NSString*)update {
    [self addRecordingWithJSONNamed:initial
                        inDirectory:@"QuerySync"
                            matcher:^BOOL(NSURLRequest *request) {
                                return [request.URL.absoluteString rangeOfString:@"entries"].location != NSNotFound && [request.URL.absoluteString rangeOfString:@"sys.updatedAt"].location == NSNotFound;
                            }];

    [self addRecordingWithJSONNamed:update
                        inDirectory:@"QuerySync"
                            matcher:^BOOL(NSURLRequest *request) {
                                return [request.URL.absoluteString rangeOfString:@"entries"].location != NSNotFound && [request.URL.absoluteString rangeOfString:@"sys.updatedAt"].location != NSNotFound;
                            }];
}

-(void)querySync_updateAsset {
    [self querySync_stubInitialRequestWithJSONNamed:@"initial2" updateWithJSONNamed:@"update-asset"];

    [self addRecordingWithJSONNamed:@"update-asset-assets"
                        inDirectory:@"QuerySync"
                            matcher:^BOOL(NSURLRequest *request) {
                                return [request.URL.absoluteString rangeOfString:@"assets"].location != NSNotFound;
                            }];

    StartBlock();

    [self.persistenceManager performSynchronizationWithSuccess:^{
        [self assertNumberOfAssets:1 numberOfEntries:2];

        id<CDAPersistedAsset> asset = [[self.persistenceManager fetchAssetsFromDataStore] firstObject];
        XCTAssertEqualObjects(@"3f5a00acf72df93528b6bb7cd0a4fd0c.jpeg",
                              asset.url.lastPathComponent, @"");

        [self.persistenceManager performSynchronizationWithSuccess:^{
            [self assertNumberOfAssets:1 numberOfEntries:2];
            XCTAssertNotEqualObjects(@"3f5a00acf72df93528b6bb7cd0a4fd0c.jpeg",
                                     asset.url.lastPathComponent, @"");

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

-(void)querySync_updateEntry {
    [self querySync_stubInitialRequestWithJSONNamed:@"initial3" updateWithJSONNamed:@"update-entry"];

    StartBlock();

    [self.persistenceManager performSynchronizationWithSuccess:^{
        [self assertNumberOfAssets:1 numberOfEntries:2];

        __block id cat = [self.persistenceManager fetchEntryWithIdentifier:@"3f1WNyJWX6sS0CKgyuCEYK"];
        XCTAssertEqualObjects(@"Post 1", [cat name], @"");

        [self.persistenceManager performSynchronizationWithSuccess:^{
            [self assertNumberOfAssets:1 numberOfEntries:2];

            cat = [self.persistenceManager fetchEntryWithIdentifier:@"3f1WNyJWX6sS0CKgyuCEYK"];
            XCTAssertEqualObjects(@"Post 1 changed!", [cat name], @"");

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

@end
