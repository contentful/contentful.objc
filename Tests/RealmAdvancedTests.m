//
//  RealmAdvancedTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 22/02/16.
//
//

#import <Realm/RLMArray.h>

#import "PersistenceBaseTest+Basic.h"
#import "RealmBaseTestCase.h"
#import "RealmClassHierarchy.h"

@class RealmGroup;

@interface RealmMember : RLMObject <CDAPersistedEntry>

@property (nonatomic, retain) NSString* identifier;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) RealmGroup *group;

@end

#pragma mark -

@implementation RealmMember

@end

RLM_ARRAY_TYPE(RealmMember)

#pragma mark -

@interface RealmGroup : RLMObject <CDAPersistedEntry>

@property (nonatomic, retain) NSString* identifier;
@property (nonatomic, retain) NSString * title;

#if __clang_major__ > 6 // Hacky way to detect if this construct will work
@property RLMArray<RealmMember *><RealmMember> *members;
#endif

@end

#pragma mark -

@implementation RealmGroup

@end

#pragma mark -

@interface RealmAdvancedTests : RealmBaseTestCase

@end

#pragma mark -

@implementation RealmAdvancedTests

-(void)buildPersistenceManagerWithDefaultClient:(BOOL)defaultClient {
    [super buildPersistenceManagerWithDefaultClient:defaultClient];

    if (!defaultClient) { return; }

    NSArray* contentTypeIds = @[ @"1nGOrvlRTaMcyyq4IEa8ea", @"6bAvxqodl6s4MoKuWYkmqe",
                                 @"6PnRGY1dxSUmaQ2Yq2Ege2", @"cat" ];
    NSDictionary* mapping = @{ @"fields.name": @"name", @"fields.bestFriend": @"bestFriend" };

    Class c = [RealmClassHierarchy class];
    for (NSString* contentTypeId in contentTypeIds) {
        [self.persistenceManager setClass:c forEntriesOfContentTypeWithIdentifier:contentTypeId];
        [self.persistenceManager setMapping:mapping forEntriesOfContentTypeWithIdentifier:contentTypeId];
    }
}

#pragma mark -

-(void)setUp {
    [super setUp];

    [self basic_setupFixtures];
}

#pragma mark -

-(void)testSyncWithClassHierarchy {
    [self removeAllStubs];
    [self buildPersistenceManagerWithDefaultClient:YES];

    StartBlock();

    [self.persistenceManager performSynchronizationWithSuccess:^{
        XCTAssertEqual(4U, [self.persistenceManager fetchAssetsFromDataStore].count, @"");
        XCTAssertEqual(3U, [self.persistenceManager fetchEntriesFromDataStore].count, @"");

        RealmClassHierarchy* nyancat = [self.persistenceManager fetchEntryWithIdentifier:@"nyancat"];
        XCTAssertNotNil(nyancat);
        RealmClassHierarchy* friend = nyancat.bestFriend;
        XCTAssertNotNil(friend);
        XCTAssertEqualObjects(friend.identifier, @"happycat");

        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);

        EndBlock();
    }];

    WaitUntilBlockCompletes();
}

-(void)testToManyRelationship {
    [self removeAllStubs];

    StartBlock();

    self.client = [[CDAClient alloc] initWithSpaceKey:@"a3rsszoo7qqp" accessToken:@"57a1ef74e87e234bed4d3f932ec945a82dae641d6ea2b2435ea2837de94d6be5"];
    [super buildPersistenceManagerWithDefaultClient:NO];

    [self.persistenceManager setClass:RealmGroup.class forEntriesOfContentTypeWithIdentifier:@"20iFrEKPwgoq6KAyeSqww8"];

#if __clang_major__ > 6 // Do not run the `members` tests when not available
    NSDictionary* mapping = @{ @"fields.title": @"title", @"fields.members": @"members" };
#else
    NSDictionary* mapping = @{ @"fields.title": @"title" };
#endif
    
    [self.persistenceManager setMapping:mapping forEntriesOfContentTypeWithIdentifier:@"20iFrEKPwgoq6KAyeSqww8"];

    [self.persistenceManager setClass:RealmMember.class forEntriesOfContentTypeWithIdentifier:@"12pXFbTH9cWqWo06Oigeyu"];
    [self.persistenceManager setMapping:@{ @"fields.name": @"title", @"fields.group": @"group" } forEntriesOfContentTypeWithIdentifier:@"12pXFbTH9cWqWo06Oigeyu"];

    [self.persistenceManager performSynchronizationWithSuccess:^{
        for (id entry in [self.persistenceManager fetchEntriesFromDataStore]) {
            if (![entry isKindOfClass:RealmGroup.class]) {
                continue;
            }
            RealmGroup* group = (RealmGroup*)entry;
            XCTAssertNotNil(group, @"");

#if __clang_major__ > 6 // Do not run the `members` tests when not available
            if ([group.identifier isEqualToString:@"8UEOnseV2gQY8GUOG8csc"]) {
                XCTAssertEqual(group.members.count, 2UL, @"");

                for (RealmMember* member in group.members) {
                    XCTAssertNotNil(member, @"");
                    XCTAssertTrue([member isKindOfClass:RealmMember.class], @"");
                }
            } else {
                XCTAssertEqual(group.members.count, 0UL, @"");
            }
#endif
        }

        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);

        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

@end
