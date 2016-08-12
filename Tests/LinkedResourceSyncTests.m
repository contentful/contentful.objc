//
//  LinkedResourceSyncTests.m
//  ContentfulSDK
//
//  Created by Jason George on 8/2/16.
//
//

#import "SyncBaseTestCase.h"

@interface LinkedResourceSyncTests : SyncBaseTestCase

@end

@implementation LinkedResourceSyncTests

-(void)setUp {
    [super setUp];
    
    
    NSDictionary* stubs = @{ @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?initial=true": @"LinkedResourceTestInitial",
                             @"https://cdn.contentful.com/spaces/emh6o2ireilu/content_types?limit=2&sys.id%5Bin%5D=collection%2Citem": @"LinkedResourceTestContentTypes",
                             @"https://cdn.contentful.com/spaces/emh6o2ireilu/content_types?limit=2&sys.id%5Bin%5D=item%2Ccollection": @"LinkedResourceTestContentTypes",
                             @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyY5SVo4wpHDo0nDpVXClcKgw7tKCTpCw5ovJw7DncOXFkJdwphhCwvCmcKdf8KQwqEnw6MuDW3CghPCusKXwojCsn4JwqNew6tweTXComLDm1PCrsKyw4zCoMO5L8Oy": @"LinkedResourceTestUpdate",
                             @"https://cdn.contentful.com/spaces/emh6o2ireilu/": @"space",
                             };
    
    [self stubHTTPRequestUsingFixtures:stubs inDirectory:@"ComplexSyncTests"];
}

-(void)testSyncLinkedEntry {
    StartBlock();
    
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response, CDASyncedSpace *space) {
        space.delegate = self;
        
        CDAEntry *collection = [self collectionInEntries:space.entries withIdentifier:@"51mdUtjJRKyGiUYGUiYiUA"];
        CDAEntry *item = [self itemInCollection:collection withIdentifier:@"4TzdkYASnum0we4C0wUueu"];
        
        XCTAssertNotNil(item, @"");
        XCTAssert([item.fields[@"description"] isEqualToString:@"Test item one"], @"");
        
        [space performSynchronizationWithSuccess:^{
            
            CDAEntry *collection = [self collectionInEntries:space.entries withIdentifier:@"51mdUtjJRKyGiUYGUiYiUA"];
            CDAEntry *item = [self itemInCollection:collection withIdentifier:@"4TzdkYASnum0we4C0wUueu"];
            
            XCTAssertNotNil(item, @"");
            XCTAssert([item.fields[@"description"] isEqualToString:@"Test item one (updated)"], @"");
            
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

-(void)testSyncLinkedAsset {
    StartBlock();
    
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response, CDASyncedSpace *space) {
        space.delegate = self;
        
        CDAEntry *collection = [self collectionInEntries:space.entries withIdentifier:@"51mdUtjJRKyGiUYGUiYiUA"];
        CDAAsset *image = [self imageInCollection:collection withIdentifier:@"6M2bp501m8kmAWW0YyQMus"];
        
        XCTAssertNotNil(image, @"");
        XCTAssert([image.URL.absoluteString isEqualToString:@"https://images.contentful.com/emh6o2ireilu/6M2bp501m8kmAWW0YyQMus/b1a7690a89e90f0638765e6b89985714/images.jpeg"], @"");
        
        [space performSynchronizationWithSuccess:^{
            
            CDAEntry *collection = [self collectionInEntries:space.entries withIdentifier:@"51mdUtjJRKyGiUYGUiYiUA"];
            CDAAsset *image = [self imageInCollection:collection withIdentifier:@"6M2bp501m8kmAWW0YyQMus"];
            
            XCTAssertNotNil(image, @"");
            XCTAssert([image.URL.absoluteString isEqualToString:@"https://images.contentful.com/emh6o2ireilu/6M2bp501m8kmAWW0YyQMus/c5785032c00eaf5b8937ffdb76b3e288/images.jpeg"], @"");
            
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

#pragma mark - Helper Methods

- (CDAEntry *)collectionInEntries:(NSArray*)entries
                   withIdentifier:(NSString*)identifier
{
    for (CDAEntry* entry in entries) {
        if ([entry.identifier isEqualToString:identifier]) {
            return entry;
        }
    }
    return nil;
}

- (CDAEntry *)itemInCollection:(CDAEntry*)collection
                withIdentifier:(NSString*)identifier
{
    NSArray *items = collection.fields[@"items"];
    for (CDAEntry* entry in items) {
        if ([entry.identifier isEqualToString:identifier]) {
            return entry;
        }
    }
    return nil;
}

- (CDAAsset *)imageInCollection:(CDAEntry*)collection
                 withIdentifier:(NSString*)identifier
{
    NSArray *images = collection.fields[@"images"];
    for (CDAAsset* image in images) {
        if ([image.identifier isEqualToString:identifier]) {
            return image;
        }
    }
    return nil;
}
@end
