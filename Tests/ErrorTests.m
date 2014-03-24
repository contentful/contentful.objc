//
//  ErrorTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 09/03/14.
//
//

#import <OHHTTPStubs/OHHTTPStubs.h>

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

- (void)testBrokenJSON
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:nil statusCode:200 headers:nil];
    }];
    
    StartBlock();
    
    [self.client fetchEntriesWithSuccess:^(CDAResponse *response,
                                           CDAArray *array) {
        XCTFail(@"Should never be reached.");
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTAssertEqual(error.code, kCFURLErrorZeroByteResource, @"");
        XCTAssertEqualObjects(error.domain, NSURLErrorDomain, @"");
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
 
    [OHHTTPStubs removeLastStub];
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

- (void)testNoNetwork
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain code:kCFURLErrorNotConnectedToInternet userInfo:nil]];
    }];
    
    StartBlock();
    
    [self.client fetchEntriesWithSuccess:^(CDAResponse *response, CDAArray *array) {
        XCTFail(@"Request should not succeed.");
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTAssertEqual(error.code, kCFURLErrorNotConnectedToInternet, @"");
        XCTAssertEqualObjects(error.domain, NSURLErrorDomain, @"");
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
    
    [OHHTTPStubs removeLastStub];
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
