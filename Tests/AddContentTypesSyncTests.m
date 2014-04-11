//
//  AddContentTypesSyncTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 11/04/14.
//
//

#import "SyncBaseTestCase.h"

@interface AddContentTypesSyncTests : SyncBaseTestCase

@end

#pragma mark -

@implementation AddContentTypesSyncTests

-(void)setUp {
    [super setUp];
    
    /*
     Map URLs to JSON response files
     */
    NSDictionary* stubs = @{ @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?access_token=1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac&initial=true": @"AddContentTypesInitial", @"https://cdn.contentful.com/spaces/emh6o2ireilu/sync?access_token=1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac&sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdybCr1IuSMKBHcKNbynCrcOdF8KoNCA_cwJHKx5VfW1EMsOBdkFww5_CjcOMQcOQw4_Dg8KjNcK8w7RrYCY8w57DmjM5wprDgcOxw7JOw7jDuQjDgsKVTsKBw7HDvcOX": @"AddContentTypesUpdate", @"https://cdn.contentful.com/spaces/emh6o2ireilu/?access_token=1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac": @"space", @"https://cdn.contentful.com/spaces/emh6o2ireilu/content_types?access_token=1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac&sys.id%5Bin%5D=5kLp8FbRwAG0kcOOYa6GMa": @"AddContentTypesContentTypes", };
    
    [self stubHTTPRequestUsingFixtures:stubs inDirectory:@"ComplexSyncTests"];
}

-(void)testAddContentTypesDuringSyncSession {
    StartBlock();
    
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response, CDASyncedSpace *space) {
        space.delegate = self;
        
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
    XCTAssertNotNil(request, @"");
    
    WaitUntilBlockCompletes();
    
    XCTAssertEqual(1U, self.numberOfEntriesCreated, @"");
}

@end
