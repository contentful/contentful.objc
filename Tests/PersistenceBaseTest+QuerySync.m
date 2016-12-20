//
//  PersistenceBaseTest+QuerySync.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 08/12/14.
//
//

#import "PersistenceBaseTest+QuerySync.h"

@implementation PersistenceBaseTest (QuerySync)

#pragma mark Setup

// TODO: rename build client
-(void)querySync_setupClient {
    self.client = [[CDAClient alloc] initWithSpaceKey:@"6mhvnnmyn9e1"
                                          accessToken:@"c054f8439246817a657ba7c5fa99989fa50db48c4893572d9537335b0c9b153e"];
    self.query = @{ @"content_type": @"6PnRGY1dxSUmaQ2Yq2Ege2" };
}

-(void)querySync_stubInitialRequestWithJSONNamed:(NSString*)initial updateWithJSONNamed:(NSString*)update {

    // Stub sync response when querying entries without any updates.
    [self addRecordingWithJSONNamed:initial
                        inDirectory:@"QuerySync"
                            matcher:^BOOL(NSURLRequest *request) {
                                return [request.URL.absoluteString rangeOfString:@"entries"].location != NSNotFound && [request.URL.absoluteString rangeOfString:@"sys.updatedAt"].location == NSNotFound;
                            }];

    // Stub sync response when querying entries with updates.
    [self addRecordingWithJSONNamed:update
                        inDirectory:@"QuerySync"
                            matcher:^BOOL(NSURLRequest *request) {
                                return [request.URL.absoluteString rangeOfString:@"entries"].location != NSNotFound && [request.URL.absoluteString rangeOfString:@"sys.updatedAt"].location != NSNotFound;
                            }];
}


#pragma mark Tests

-(void)querySync_addEntry {
    [self querySync_stubInitialRequestWithJSONNamed:@"initial" updateWithJSONNamed:@"add-entry"];

    StartBlock();

    [self.persistenceManager performSynchronizationWithSuccess:^{
        XCTAssertEqual(1, [self.persistenceManager fetchAssetsFromDataStore].count, @"");
        XCTAssertEqual(2, [self.persistenceManager fetchEntriesFromDataStore].count, @"");

        NSDate* timestamp = [self.persistenceManager fetchSpaceFromDataStore].lastSyncTimestamp;
        if (![[timestamp description] hasSuffix:@":00 +0000"]) {
            XCTAssertNotEqualObjects(self.lastSyncTimestamp, timestamp, @"");
        }
        self.lastSyncTimestamp = timestamp;

        [self.persistenceManager performSynchronizationWithSuccess:^{

            XCTAssertEqual(2, [self.persistenceManager fetchAssetsFromDataStore].count, @"");
            XCTAssertEqual(3, [self.persistenceManager fetchEntriesFromDataStore].count, @"");

            NSDate* timestamp = [self.persistenceManager fetchSpaceFromDataStore].lastSyncTimestamp;
            if (![[timestamp description] hasSuffix:@":00 +0000"]) {
                XCTAssertNotEqualObjects(self.lastSyncTimestamp, timestamp, @"");
            }
            self.lastSyncTimestamp = timestamp;

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
        XCTAssertNil(asset.assetDescription);
        XCTAssertEqualObjects(@"3f5a00acf72df93528b6bb7cd0a4fd0c", asset.title);

        [self.persistenceManager performSynchronizationWithSuccess:^{
            [self assertNumberOfAssets:1 numberOfEntries:2];
            XCTAssertNotEqualObjects(@"3f5a00acf72df93528b6bb7cd0a4fd0c.jpeg",
                                     asset.url.lastPathComponent, @"");
            XCTAssertEqualObjects(@"yolo", asset.assetDescription);
            XCTAssertEqualObjects(@"3f5a00acf72df93528b6bb7cd0a4fd0c", asset.title);

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
