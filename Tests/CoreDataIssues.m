//
//  CoreDataIssues.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 03/09/14.
//
//

#import "CoreDataBaseTestCase.h"
#import "Group.h"
#import "Member.h"

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

-(void)testToManyRelationship {
    StartBlock();

    self.client = [[CDAClient alloc] initWithSpaceKey:@"a3rsszoo7qqp" accessToken:@"57a1ef74e87e234bed4d3f932ec945a82dae641d6ea2b2435ea2837de94d6be5"];
    [super buildCoreDataManagerWithDefaultClient:NO];

    [self.coreDataManager setClass:Group.class forEntriesOfContentTypeWithIdentifier:@"20iFrEKPwgoq6KAyeSqww8"];
    [self.coreDataManager setMapping:@{ @"fields.title": @"title", @"fields.members": @"members" }forEntriesOfContentTypeWithIdentifier:@"20iFrEKPwgoq6KAyeSqww8"];

    [self.coreDataManager setClass:Member.class forEntriesOfContentTypeWithIdentifier:@"12pXFbTH9cWqWo06Oigeyu"];
    [self.coreDataManager setMapping:@{ @"fields.name": @"title", @"fields.group": @"group" } forEntriesOfContentTypeWithIdentifier:@"12pXFbTH9cWqWo06Oigeyu"];

    [self.coreDataManager performSynchronizationWithSuccess:^{
        for (Group* group in [self.coreDataManager fetchEntriesOfContentTypeWithIdentifier:@"20iFrEKPwgoq6KAyeSqww8" matchingPredicate:nil]) {
            XCTAssertNotNil(group, @"");

            if ([group.identifier isEqualToString:@"8UEOnseV2gQY8GUOG8csc"]) {
                XCTAssertEqual(group.members.count, 2UL, @"");

                for (Member* member in group.members) {
                    XCTAssertNotNil(member, @"");
                    XCTAssertTrue([member isKindOfClass:Member.class], @"");
                }
            } else {
                XCTAssertEqual(group.members.count, 0UL, @"");
            }
        }

        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);

        EndBlock();
    }];

    WaitUntilBlockCompletes();
}

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
