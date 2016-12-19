//
//  PersistenceBaseTest.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 08/12/14.
//
//

#import "PersistenceBaseTest.h"

@interface PersistenceBaseTest ()

@property (nonatomic) CDAPersistenceManager* persistenceManager;

@end

#pragma mark -

@implementation PersistenceBaseTest

-(void)setUp {
    [super setUp];

    self.lastSyncTimestamp = nil;

    [self buildPersistenceManagerWithDefaultClient:NO];

    [self deleteStore];
}

-(void)tearDown {
    [super tearDown];

    self.persistenceManager = nil;
}

- (void)deleteStore {
    [NSException raise:@"Delete not implemented" format:@"Must implement deleteStore method"];
}

-(void)assertNumberOfAssets:(NSUInteger)numberOfAssets numberOfEntries:(NSUInteger)numberOfEntries {
    XCTAssertEqual(numberOfAssets, [self.persistenceManager fetchAssetsFromDataStore].count, @"");
    XCTAssertEqual(numberOfEntries, [self.persistenceManager fetchEntriesFromDataStore].count, @"");

    NSDate* timestamp = [self.persistenceManager fetchSpaceFromDataStore].lastSyncTimestamp;
    if (![[timestamp description] hasSuffix:@":00 +0000"]) {
        XCTAssertNotEqualObjects(self.lastSyncTimestamp, timestamp, @"");
    }
    self.lastSyncTimestamp = timestamp;
}

-(void)buildPersistenceManagerWithDefaultClient:(BOOL)defaultClient {
    CDAClient* client = defaultClient ? [CDAClient new] : self.client;

    self.persistenceManager = [self createPersistenceManagerWithClient:client];

    NSArray* contentTypeIds = @[
                                @"1nGOrvlRTaMcyyq4IEa8ea",
                                @"6bAvxqodl6s4MoKuWYkmqe",
                                @"6PnRGY1dxSUmaQ2Yq2Ege2",
                                @"cat"
                               ];

    NSMutableDictionary* mapping = [@{ @"fields.color": @"color",
                                       @"fields.lives": @"livesLeft",
                                       @"fields.image": @"picture" } mutableCopy];

    if (defaultClient) {
        mapping[@"fields.name"] = @"name";
    } else {
        mapping[@"fields.title"] = @"name";
    }

    for (NSString* contentTypeId in contentTypeIds) {
        [self.persistenceManager setMapping:mapping forEntriesOfContentTypeWithIdentifier:contentTypeId];
    }
}

-(CDAPersistenceManager*)createPersistenceManagerWithClient:(CDAClient*)client {
    return nil;
}

@end
