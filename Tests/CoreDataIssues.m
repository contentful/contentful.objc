//
//  CoreDataIssues.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 03/09/14.
//
//

#import "CoreDataBaseTestCase.h"

@interface CoreDataIssues : CoreDataBaseTestCase

@end

#pragma mark -

@implementation CoreDataIssues

-(void)buildCoreDataManagerWithDefaultClient:(BOOL)defaultClient {
    self.client = [CDAClient new];
    self.query = @{ @"order": @"sys.createdAt" };

    [super buildCoreDataManagerWithDefaultClient:NO];
}

#pragma mark -

-(void)testUnmappedContentType {
    StartBlock();

    [self.coreDataManager performSynchronizationWithSuccess:^{
        XCTAssertTrue(true, @"");

        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);

        EndBlock();
    }];

    WaitUntilBlockCompletes();
}

@end
