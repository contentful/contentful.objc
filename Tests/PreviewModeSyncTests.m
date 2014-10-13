//
//  PreviewModeSyncTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 14/04/14.
//
//

#import "SyncBaseTestCase.h"

@interface PreviewModeSyncTests : SyncBaseTestCase

@end

#pragma mark -

@implementation PreviewModeSyncTests

-(CDAClient*)buildClient {
    CDAConfiguration* configuration = [CDAConfiguration defaultConfiguration];
    configuration.previewMode = YES;
    return [[CDAClient alloc] initWithSpaceKey:@"emh6o2ireilu" accessToken:@"3396581609dda9ddb19140eb8acb2216a9f33895b178e83a7dee7c75793c8243" configuration:configuration];
}

-(void)testInitialSync {
    StartBlock();
    
    CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response, CDASyncedSpace *space) {
        XCTAssertEqual(2U, space.assets.count, @"");
        XCTAssertEqual(9U, space.entries.count, @"");
        
        [space performSynchronizationWithSuccess:^{
            XCTAssertEqual(2U, space.assets.count, @"");
            XCTAssertEqual(9U, space.entries.count, @"");
            
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

@end
