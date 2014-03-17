//
//  ErrorTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 09/03/14.
//
//

#import "ContentfulBaseTestCase.h"

@interface ErrorTests : ContentfulBaseTestCase

@end

#pragma mark -

@implementation ErrorTests

- (void)testNonLocationFieldsThrow
{
    StartBlock();
    
    [self.client fetchEntryWithIdentifier:@"nyancat" success:^(CDAResponse *response, CDAEntry *entry) {
        XCTAssertThrowsSpecificNamed([entry CLLocationCoordinate2DFromFieldWithIdentifier:@"bestFriend"],
                                     NSException, NSInvalidArgumentException, @"");
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

@end
