//
//  CoreDataLinkDeletionTests.m
//  
//
//  Created by Boris Bügling on 24/09/15.
//
//

#import "CoreDataBaseTestCase.h"
#import "CoreDataManager.h"
#import "LinkedEntry.h"
#import "SyncInfo.h"

@interface CoreDataLinkDeletionTests : CoreDataBaseTestCase

@end

#pragma mark -

@implementation CoreDataLinkDeletionTests

-(void)buildPersistenceManagerWithDefaultClient:(BOOL)defaultClient {
    self.client = [[CDAClient alloc] initWithSpaceKey:@"hsut5b3lu3cv" accessToken:@"370d14bd130e39083728b8f219886d6ea72f6ca2dc792957af1ae6e50c8ca64c"];

    [super buildPersistenceManagerWithDefaultClient:NO];

    [self.persistenceManager setClass:[LinkedEntry class] forEntriesOfContentTypeWithIdentifier:@"SUHIqy1t2USm0iuIgYGMU"];
}

-(CDAPersistenceManager*)createPersistenceManagerWithClient:(CDAClient*)client {
    return [[CoreDataManager alloc] initWithClient:client dataModelName:@"LinkedData"];
}

-(void)setUp {
    [super setUp];

    NSDictionary* stubs = @{ @"https://cdn.contentful.com/spaces/hsut5b3lu3cv/sync?initial=true": @"initial", @"https://cdn.contentful.com/spaces/hsut5b3lu3cv/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyY6XTXDhsOALVLDh2TCn8O0LsO-w7AcImrCh3tAJwDDn2tHw4Jhw7p3DsOoBwjCrmlZfx7Cn2HCugnDisK1wqfDgnhHw5pzRMOUwq8XMy5uKR82wqbCpn7Crw": @"link-deleted", @"https://cdn.contentful.com/spaces/hsut5b3lu3cv/": @"space", @"https://cdn.contentful.com/spaces/hsut5b3lu3cv/content_types?limit=1&sys.id%5Bin%5D=SUHIqy1t2USm0iuIgYGMU": @"content-types", @"https://cdn.contentful.com/spaces/hsut5b3lu3cv/content_types": @"all-content-types" };

    [self stubHTTPRequestUsingFixtures:stubs inDirectory:@"LinkDeletion"];
}

#pragma mark -

-(void)testNoLongerExistingLinksGetDeletedOnSync {
    [self buildPersistenceManagerWithDefaultClient:NO];

    StartBlock();

    [self.persistenceManager performSynchronizationWithSuccess:^{
        XCTAssertEqual(0U, [self.persistenceManager fetchAssetsFromDataStore].count, @"");
        XCTAssertEqual(2U, [self.persistenceManager fetchEntriesFromDataStore].count, @"");

        LinkedEntry* entry = (LinkedEntry*)[self.persistenceManager fetchEntryWithIdentifier:@"1sPD1WORSoyCEKqyM00uck"];
        XCTAssertNotNil(entry.link);
        XCTAssertEqualObjects(@"B", entry.link.name);

        [self.persistenceManager performSynchronizationWithSuccess:^{
            LinkedEntry* e = (LinkedEntry*)[self.persistenceManager fetchEntryWithIdentifier:@"1sPD1WORSoyCEKqyM00uck"];
            XCTAssertNil(e.link);

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

//
