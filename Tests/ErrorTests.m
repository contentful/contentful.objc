//
//  ErrorTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 09/03/14.
//
//

#import "CDAResource+Private.h"
#import "ContentfulBaseTestCase.h"

@interface ErrorTests : ContentfulBaseTestCase

@end

#pragma mark -

@implementation ErrorTests

- (CDAEntry*)customEntryHelperWithFields:(NSDictionary*)fields
{
    NSDictionary* ct = @{
                         @"name": @"My trolls",
                         @"fields": @[
                                 @{ @"id": @"someArray",    @"type": @"Array" },
                                 @{ @"id": @"someBool",     @"type": @"Boolean" },
                                 @{ @"id": @"someDate",     @"type": @"Date" },
                                 @{ @"id": @"someInteger",  @"type": @"Integer" },
                                 @{ @"id": @"someLink",     @"type": @"Link" },
                                 @{ @"id": @"someLocation", @"type": @"Location" },
                                 @{ @"id": @"someNumber",   @"type": @"Number" },
                                 @{ @"id": @"someSymbol",   @"type": @"Symbol" },
                                 @{ @"id": @"someText",     @"type": @"Text" },
                                 ],
                         @"sys": @{ @"id": @"trolololo" },
                         };
    
    CDAContentType* contentType = [[CDAContentType alloc] initWithDictionary:ct client:self.client];
    XCTAssertEqual(9U, contentType.fields.count, @"");
    
    NSDictionary* entry = @{
                            @"fields": fields,
                            @"sys": @{
                                    @"id": @"brokenEntry",
                                    @"contentType": @{ @"sys": @{ @"id": @"trolololo" } }
                                    },
                            };
    CDAEntry* brokenEntry = [[CDAEntry alloc] initWithDictionary:entry client:self.client];
    XCTAssertEqualObjects(@"brokenEntry", brokenEntry.identifier, @"");
    return brokenEntry;
}

- (void)testBrokenContent
{
    CDAEntry* brokenEntry = [self customEntryHelperWithFields:@{
                                                                @"someArray": @1,
                                                                @"someBool": @"foo",
                                                                @"someDate": @[],
                                                                @"someInteger": @{},
                                                                @"someLink": @YES,
                                                                @"someLocation": @23,
                                                                @"someNumber": @{},
                                                                @"someSymbol": @7,
                                                                @"someText": @[],
                                                                }];
    
    XCTAssertEqualObjects(@[], brokenEntry.fields[@"someArray"], @"");
    XCTAssertEqual(NO, [brokenEntry.fields[@"someBool"] boolValue], @"");
    XCTAssertNil(brokenEntry.fields[@"someDate"], @"");
    XCTAssertEqualObjects(@0, brokenEntry.fields[@"someInteger"], @"");
    XCTAssertNil(brokenEntry.fields[@"someLink"], @"");
    XCTAssertEqualObjects(@0, brokenEntry.fields[@"someNumber"], @"");
    XCTAssertEqualObjects(@"7", brokenEntry.fields[@"someSymbol"], @"");
    XCTAssertEqualObjects(@"", brokenEntry.fields[@"someText"], @"");
}

- (void)testHoldStrongReferenceToClientUntilRequestIsDone
{
    StartBlock();
    
    CDAClient* client = [CDAClient new];
    [client fetchAssetsWithSuccess:^(CDAResponse *response, CDAArray *array) {
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
     
        EndBlock();
    }];
    client = nil;
    
    WaitUntilBlockCompletes();
}

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

- (void)testNulledContent
{
    CDAEntry* brokenEntry = [self customEntryHelperWithFields:@{
                                                                @"someArray": [NSNull null],
                                                                @"someBool": [NSNull null],
                                                                @"someDate": [NSNull null],
                                                                @"someInteger": [NSNull null],
                                                                @"someLink": [NSNull null],
                                                                @"someLocation": [NSNull null],
                                                                @"someNumber": [NSNull null],
                                                                @"someSymbol": [NSNull null],
                                                                @"someText": [NSNull null],
                                                                }];
    
    XCTAssertEqualObjects(@[], brokenEntry.fields[@"someArray"], @"");
    XCTAssertEqual(NO, [brokenEntry.fields[@"someBool"] boolValue], @"");
    XCTAssertNil(brokenEntry.fields[@"someDate"], @"");
    XCTAssertEqualObjects(@0, brokenEntry.fields[@"someInteger"], @"");
    XCTAssertNil(brokenEntry.fields[@"someLink"], @"");
    XCTAssertEqualObjects(@0, brokenEntry.fields[@"someNumber"], @"");
    XCTAssertEqualObjects(@"", brokenEntry.fields[@"someSymbol"], @"");
    XCTAssertEqualObjects(@"", brokenEntry.fields[@"someText"], @"");
}

@end
