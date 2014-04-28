//
//  CoreDataQuerySyncTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 28/04/14.
//
//

#import "CoreDataBaseTestCase.h"

@interface CoreDataQuerySyncTests : CoreDataBaseTestCase

@end

@implementation CoreDataQuerySyncTests

-(void)buildCoreDataManagerWithDefaultClient:(BOOL)defaultClient {
    self.client = [[CDAClient alloc] initWithSpaceKey:@"6mhvnnmyn9e1" accessToken:@"c054f8439246817a657ba7c5fa99989fa50db48c4893572d9537335b0c9b153e"];
    self.query = @{ @"content_type": @"6PnRGY1dxSUmaQ2Yq2Ege2" };
    
    [super buildCoreDataManagerWithDefaultClient:NO];
}

#pragma mark -

-(void)testInitialSync {
    StartBlock();
    
    [self.coreDataManager performSynchronizationWithSuccess:^{
        [self assertNumberOfAssets:0 numberOfEntries:2];
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

@end
