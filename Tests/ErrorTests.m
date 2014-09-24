//
//  ErrorTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 09/03/14.
//
//

@import ObjectiveC.runtime;

#import "CDAResource+Private.h"
#import "ContentfulBaseTestCase.h"

@interface ErrorTestsMapTargetAsset : NSObject

@property (nonatomic) NSString* identifier;
@property (nonatomic) NSString* myDescription;
@property (nonatomic) NSInteger size;
@property (nonatomic) NSString* title;
@property (nonatomic) NSURL* url;

@end

#pragma mark -

@implementation ErrorTestsMapTargetAsset

@end

#pragma mark -

@interface ErrorTestsMapTargetObject : NSObject

@property (nonatomic) NSArray* someArray;
@property (nonatomic) BOOL someBool;
@property (nonatomic) NSDate* someDate;
@property (nonatomic) NSInteger someInteger;
@property (nonatomic) CDAEntry* someLink;
@property (nonatomic) NSData* someLocation;
@property (nonatomic) CGFloat someNumber;
@property (nonatomic) NSString* someSymbol;
@property (nonatomic) NSString* someText;

@end

#pragma mark -

@implementation ErrorTestsMapTargetObject

@end

#pragma mark -

@interface ErrorTests : ContentfulBaseTestCase

@end

#pragma mark -

@implementation ErrorTests

+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request
                 returningResponse:(NSURLResponse * __autoreleasing *)response
                             error:(NSError * __autoreleasing *)error
{
    *error = [NSError errorWithDomain:NSURLErrorDomain
                                 code:kCFURLErrorNotConnectedToInternet
                             userInfo:nil];
    return nil;
}

#pragma mark -

- (void)noNetworkTestHelperWithContentTypeFetchedEarlier:(BOOL)contentTypeFetched
{
    SEL sendSyncRequest = @selector(sendSynchronousRequest:returningResponse:error:);
    Method urlOriginalMethod = class_getClassMethod(NSURLConnection.class, sendSyncRequest);
    Method urlNewMethod = class_getClassMethod(self.class, sendSyncRequest);
    method_exchangeImplementations(urlOriginalMethod, urlNewMethod);
    
    [self addResponseWithError:[NSError errorWithDomain:NSURLErrorDomain
                                                   code:kCFURLErrorNotConnectedToInternet
                                               userInfo:nil]
                       matcher:^BOOL(NSURLRequest *request) {
                           return YES;
                       }];
    
    if (contentTypeFetched) {
        [self customEntryHelperWithFields:@{}];
    }
    
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
    
    [self removeAllStubs];
    
    method_exchangeImplementations(urlNewMethod, urlOriginalMethod);
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
    [self addResponseWithData:nil statusCode:200 headers:nil matcher:^BOOL(NSURLRequest *request) {
        return YES;
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
 
    [self removeAllStubs];
}

- (void)testJSONArrayInResponse
{
    [self addResponseWithData:[NSJSONSerialization dataWithJSONObject:@[] options:0 error:nil]
                   statusCode:200
                      headers:@{ @"Content-Type": @"application/vnd.contentful.delivery.v1+json" }
                      matcher:^BOOL(NSURLRequest *request) {
                          return YES;
                      }];
    
    StartBlock();
    
    [self.client fetchEntriesWithSuccess:^(CDAResponse *response,
                                           CDAArray *array) {
        XCTFail(@"Should never be reached.");
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTAssertNotNil(error, @"");
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
    
    [self removeAllStubs];
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
    [self noNetworkTestHelperWithContentTypeFetchedEarlier:NO];
}

- (void)testNoNetworkLater
{
    [self noNetworkTestHelperWithContentTypeFetchedEarlier:YES];
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

- (void)testNonResolvableError
{
    StartBlock();
    
    self.client = [[CDAClient alloc] initWithSpaceKey:@"lt0wgui2v3eq" accessToken:@"b45994ce21e51210fdfde1b048a5528bb2d09ac16751134741121c17c7a65a05"];
    [self.client fetchEntriesWithSuccess:^(CDAResponse *response, CDAArray *array) {
        XCTAssertEqual(1U, array.errors.count, @"");
        
        NSError* error = [array.errors firstObject];
        XCTAssertEqual(0, error.code, @"");
        XCTAssertEqualObjects(CDAErrorDomain, error.domain, @"");
        XCTAssertEqualObjects(@"", error.localizedDescription, @"");
        XCTAssertEqualObjects(@"notResolvable", error.userInfo[@"identifier"], @"");
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

- (void)testNulledContentForAssets
{
    NSDictionary* assetDictionary = @{ @"sys": @{ @"identifier": [NSNull null], @"type": @"Asset" },
                                       @"fields": @{ @"file": @{ @"url": [NSNull null],
                                                                 @"details": @{ @"size": [NSNull null] } },
                                                     @"title": [NSNull null],
                                                     @"description": [NSNull null],
                                                     },
                                       };
    
    CDAAsset* brokenAsset = [[CDAAsset alloc] initWithDictionary:assetDictionary
                                                          client:[CDAClient new]];
    
    XCTAssertNil(brokenAsset.identifier, @"");
    XCTAssertNil(brokenAsset.fields[@"description"], @"");
    XCTAssertNil(brokenAsset.fields[@"title"], @"");
    XCTAssertNil(brokenAsset.URL, @"");
    XCTAssertEqualObjects(@0, brokenAsset.fields[@"file"][@"details"][@"size"], @"");
    
    CDAEntry* brokenEntry = [self customEntryHelperWithFields:@{ @"someLink": assetDictionary }];
    ErrorTestsMapTargetAsset* target = [ErrorTestsMapTargetAsset new];
    [brokenEntry mapFieldsToObject:target
                      usingMapping:@{
                                     @"fields.someLink.identifier": @"identifier",
                                     @"fields.someLink.fields.title": @"title",
                                     @"fields.someLink.fields.description": @"myDescription",
                                     @"fields.someLink.fields.file.details.size": @"size",
                                     @"fields.someLink.URL": @"url",
                                     }];
    
    XCTAssertNil(target.identifier, @"");
    XCTAssertNil(target.myDescription, @"");
    XCTAssertNil(target.title, @"");
    XCTAssertNil(target.url, @"");
    XCTAssertEqual(0, target.size, @"");
}

- (void)testNulledContentForEntries
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
    
    ErrorTestsMapTargetObject* target = [ErrorTestsMapTargetObject new];
    [brokenEntry mapFieldsToObject:target usingMapping:@{
                                                         @"fields.someArray": @"someArray",
                                                         @"fields.someBool": @"someBool",
                                                         @"fields.someDate": @"someDate",
                                                         @"fields.someInteger": @"someInteger",
                                                         @"fields.someLink": @"someLink",
                                                         @"fields.someLocation": @"someLocation",
                                                         @"fields.someNumber": @"someNumber",
                                                         @"fields.someSymbol": @"someSymbol",
                                                         @"fields.someText": @"someText",
                                                         }];
    
    XCTAssertEqualObjects(@[], target.someArray, @"");
    XCTAssertEqual(NO, target.someBool, @"");
    XCTAssertNil(target.someDate, @"");
    XCTAssertEqual(0, target.someInteger, @"");
    XCTAssertNil(target.someLink, @"");
    XCTAssertEqual(0.0f, target.someNumber, @"");
    XCTAssertEqualObjects(@"", target.someSymbol, @"");
    XCTAssertEqualObjects(@"", target.someText, @"");
}

@end
