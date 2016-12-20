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
    // MUST BE CALLED SO THAT THE STUBS ARE ACTUALLY RETURNED.
    [self setUpCCLRequestReplayForNSURLSession];

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


    // FIXME: make this is a helper method that returns a BOOl and then check for equality elsewhere.
    NSDate* timestamp = [self.persistenceManager fetchSpaceFromDataStore].lastSyncTimestamp;
    if (![[timestamp description] hasSuffix:@":00 +0000"]) {
        XCTAssertNotEqualObjects(self.lastSyncTimestamp, timestamp, @"");
    }
    self.lastSyncTimestamp = timestamp;
}

// FIXME: don't pass in a BOOL here it. Pass in the client.
// FIXME: rename method to describe that mappings are definied and classes for entries with content types are also defined.
-(void)buildPersistenceManagerWithDefaultClient:(BOOL)defaultClient {
    CDAClient* client = defaultClient ? [CDAClient new] : self.client;

    self.persistenceManager = [self createPersistenceManagerWithClient:client];

    // Because of URLConnection -> Session changes. we must re-setup CCLRequestReplay for URL Session every time we create a new client so that the recordings are correctly fetched.
    [self setUpCCLRequestReplayForNSURLSession];
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
    // FIXME: Find if this is really an 'abstract' method and if so, make a protocol instead of having a base implementation that returns nil.
    return nil;
}

@end
