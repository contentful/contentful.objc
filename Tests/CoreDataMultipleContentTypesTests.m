//
//  CoreDataMultipleContentTypesTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 14/07/14.
//
//

#import "CoreDataBaseTestCase.h"
#import "CoreDataManager.h"

@interface TestCoreDataManager : CoreDataManager

@end

#pragma mark -

@implementation TestCoreDataManager

- (NSAttributeDescription*)attributeWithName:(NSString*)name type:(NSAttributeType)type {
    NSAttributeDescription* veryAttribute = [NSAttributeDescription new];
    veryAttribute.name = name;
    veryAttribute.attributeType = type;
    return veryAttribute;
}

- (NSEntityDescription*)entityWithName:(NSString*)name {
    NSEntityDescription* suchEntity = [NSEntityDescription new];
    suchEntity.name = name;
    suchEntity.managedObjectClassName = suchEntity.name;
    return suchEntity;
}

- (NSManagedObjectModel *)managedObjectModel {
    NSManagedObjectModel *model = [NSManagedObjectModel new];

    NSEntityDescription* suchEntity = [self entityWithName:@"SuchEntityClass"];
    suchEntity.properties = @[ [self attributeWithName:@"colour" type:NSStringAttributeType],
                               [self attributeWithName:@"identifier" type:NSStringAttributeType],
                               [self attributeWithName:@"name" type:NSStringAttributeType] ];

    NSEntityDescription* wow = [self entityWithName:@"WowClass"];
    wow.properties = @[ [self attributeWithName:@"colour" type:NSInteger64AttributeType],
                        [self attributeWithName:@"identifier" type:NSStringAttributeType],
                        [self attributeWithName:@"name" type:NSStringAttributeType] ];

    NSEntityDescription* mySpace = [self entityWithName:@"MySpace"];
    mySpace.properties = @[ [self attributeWithName:@"identifier" type:NSStringAttributeType],
                            [self attributeWithName:@"lastSyncTimestamp" type:NSDateAttributeType],
                            [self attributeWithName:@"syncToken" type:NSStringAttributeType] ];

    [model setEntities:@[ suchEntity, wow, mySpace ]];
	return model;
}

@end

#pragma mark -

@interface SuchEntityClass : NSManagedObject <CDAPersistedEntry>

@property (nonatomic) NSString* colour;
@property (nonatomic) NSString* identifier;
@property (nonatomic) NSString* name;

@end

#pragma mark -


@implementation SuchEntityClass

@dynamic colour;
@dynamic identifier;
@dynamic name;

@end

#pragma mark -

@interface WowClass : NSManagedObject <CDAPersistedEntry>

@property (nonatomic) NSNumber* colour;
@property (nonatomic) NSString* identifier;
@property (nonatomic) NSString* name;

@end

#pragma mark -

@implementation WowClass

@dynamic colour;
@dynamic identifier;
@dynamic name;

@end

#pragma mark -

@interface MySpace : NSManagedObject <CDAPersistedSpace>

@property (nonatomic) NSString* identifier;
@property (nonatomic) NSDate* lastSyncTimestamp;
@property (nonatomic) NSString* syncToken;

@end

#pragma mark -

@implementation MySpace

@dynamic identifier;
@dynamic lastSyncTimestamp;
@dynamic syncToken;

@end

#pragma mark -

@interface CoreDataMultipleContentTypesTests : CoreDataBaseTestCase

@end

#pragma mark -

@implementation CoreDataMultipleContentTypesTests

- (void)testMapping {
    static NSString* const suchEntryId = @"6cg3mEgkMM2WimqqAIG2Ak";
    static NSString* const wowId = @"1uQBnveDE4yqaa0aKIiqQc";

    self.client = [[CDAClient alloc] initWithSpaceKey:@"2007f97z5ihj" accessToken:@"7d75d1d4f8fcbee0ad4eaa6ef61981dd8625313a8497390c409f56e57d9d8812"];
    CoreDataManager* manager = [[TestCoreDataManager alloc] initWithClient:self.client
                                                             dataModelName:@"foobar"];
    [self deleteStore];

    manager.classForAssets = [NSObject class];
    manager.classForSpaces = [MySpace class];

    [manager setClass:[SuchEntityClass class] forEntriesOfContentTypeWithIdentifier:suchEntryId];
    [manager setClass:[WowClass class] forEntriesOfContentTypeWithIdentifier:wowId];

    StartBlock();

    [manager performSynchronizationWithSuccess:^{
        SuchEntityClass* suchEntry = [manager fetchEntriesOfContentTypeWithIdentifier:suchEntryId
                                                                    matchingPredicate:nil].firstObject;
        XCTAssertNotNil(suchEntry, @"");
        XCTAssertEqualObjects(@"Some Entry", suchEntry.name, @"");
        XCTAssertEqualObjects(@"black", suchEntry.colour, @"");

        WowClass* wowEntry = [manager fetchEntriesOfContentTypeWithIdentifier:wowId
                                                            matchingPredicate:nil].firstObject;
        XCTAssertNotNil(wowEntry, @"");
        XCTAssertEqualObjects(@"Another Entry", wowEntry.name, @"");
        XCTAssertEqualObjects(@7, wowEntry.colour, @"");

        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);

        EndBlock();
    }];

    WaitUntilBlockCompletes();
}

@end
