//
//  CoreDataBaseTestCase.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 28/04/14.
//
//

#import "CoreDataBaseTestCase.h"
#import "SyncInfo.h"

@interface CoreDataBaseTestCase ()

@property (nonatomic) CoreDataManager* coreDataManager;
@property (nonatomic) NSDate* lastSyncTimestamp;

@end

#pragma mark -

@implementation CoreDataBaseTestCase

-(void)assertNumberOfAssets:(NSUInteger)numberOfAssets numberOfEntries:(NSUInteger)numberOfEntries {
    XCTAssertEqual(numberOfAssets, [self.coreDataManager fetchAssetsFromDataStore].count, @"");
    XCTAssertEqual(numberOfEntries, [self.coreDataManager fetchEntriesFromDataStore].count, @"");
    
    NSDate* timestamp = [self.coreDataManager fetchSpaceFromDataStore].lastSyncTimestamp;
    if (![[timestamp description] hasSuffix:@":00 +0000"]) {
        XCTAssertNotEqualObjects(self.lastSyncTimestamp, timestamp, @"");
    }
    self.lastSyncTimestamp = timestamp;
}

-(void)buildCoreDataManagerWithDefaultClient:(BOOL)defaultClient {
    CDAClient* client = defaultClient ? [CDAClient new] : self.client;
    
    if (self.query) {
        self.coreDataManager = [[CoreDataManager alloc] initWithClient:client
                                                         dataModelName:@"CoreDataExample"
                                                                 query:self.query];
    } else {
        self.coreDataManager = [[CoreDataManager alloc] initWithClient:client
                                                         dataModelName:@"CoreDataExample"];
    }
    
    self.coreDataManager.classForAssets = [Asset class];
    self.coreDataManager.classForEntries = [ManagedCat class];
    self.coreDataManager.classForSpaces = [SyncInfo class];
    
    NSMutableDictionary* mapping = [@{ @"contentType.identifier": @"contentTypeIdentifier",
                                       @"fields.color": @"color",
                                       @"fields.lives": @"livesLeft",
                                       @"fields.image": @"picture" } mutableCopy];
    
    if (defaultClient) {
        mapping[@"fields.name"] = @"name";
    } else {
        mapping[@"fields.title"] = @"name";
    }
    
    self.coreDataManager.mappingForEntries = mapping;
}

-(void)setUp {
    [super setUp];
    
    self.lastSyncTimestamp = nil;
    
    [self buildCoreDataManagerWithDefaultClient:NO];
    [[NSFileManager defaultManager] removeItemAtURL:self.coreDataManager.storeURL
                                              error:nil];
}

-(void)tearDown {
    [super tearDown];
    
    self.coreDataManager = nil;
    [[NSFileManager defaultManager] removeItemAtURL:self.coreDataManager.storeURL
                                              error:nil];
}

#pragma mark -

@end
