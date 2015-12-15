//
//  UtilityTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 28/03/14.
//
//

#import "CDAClient+Private.h"
#import "CDAContentTypeRegistry.h"
#import "CDAFallbackDictionary.h"
#import "CDAResource+Private.h"
#import "CDAUtilities.h"
#import "ContentfulBaseTestCase.h"

@interface UtilityTests : ContentfulBaseTestCase

@end

#pragma mark -

@implementation UtilityTests

-(void)assertCacheFile:(NSString*)cacheFileName againstSuffix:(NSString*)suffix {
    NSString* cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                                NSUserDomainMask, YES) lastObject];
    XCTAssert([cacheFileName hasPrefix:cachesPath], @"Does not reside in caches path.");
    XCTAssert([cacheFileName hasSuffix:suffix], @"");
    XCTAssertEqualObjects(suffix.lastPathComponent, cacheFileName.lastPathComponent, @"");
    
    NSError* error;
    XCTAssert([@"foo" writeToFile:cacheFileName atomically:YES encoding:NSUTF8StringEncoding
                            error:&error], @"Error: %@", error);
    
    NSString* result = [NSString stringWithContentsOfFile:cacheFileName
                                                 encoding:NSUTF8StringEncoding
                                                    error:&error];
    
    XCTAssertNotNil(result, @"Error: %@", error);
    XCTAssertEqualObjects(@"foo", result, @"");
}

#pragma mark -

-(void)testBasic {
    NSDictionary* dict = @{ @"foo": @1, @"bar": @2 };
    NSDictionary* otherDict = @{ @"moo": @42 };
    
    NSMutableDictionary* all = [dict mutableCopy];
    [all addEntriesFromDictionary:otherDict];
    
    CDAFallbackDictionary* fallbackDict = [[CDAFallbackDictionary alloc] initWithDictionary:dict
                                                                         fallbackDictionary:otherDict];
    
    XCTAssertEqual(3U, fallbackDict.count, @"");
    XCTAssertEqualObjects(all, fallbackDict, @"");
}

-(void)testCacheFileNameForQuery {
    StartBlock();
    
    CDAClient* client = [CDAClient new];
    [client fetchSpaceWithSuccess:^(CDAResponse *response, CDASpace *space) {
        NSString* cacheFileName = CDACacheFileNameForQuery(client,
                                                           CDAResourceTypeAsset, @{ @"foo": @"bar" });
        [self assertCacheFile:cacheFileName againstSuffix:@"com.contentful.sdk/cache_cfexampleapi_0_{foo=bar;}.data"];
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

-(void)testCacheFileNameForResource {
    StartBlock();
    
    CDAClient* client = [CDAClient new];
    [client fetchSpaceWithSuccess:^(CDAResponse *response, CDASpace *space) {
        CDAResource* resource = [CDAResource resourceObjectForDictionary:@{ @"sys": @{ @"id": @"foo", @"type": @"Asset" }, @"fields": @{ @"file": @{ @"url": @"file:///test/test.foo" } } }
                                                                  client:client];
        NSString* cacheFileName = CDACacheFileNameForResource(resource);
        [self assertCacheFile:cacheFileName againstSuffix:@"com.contentful.sdk/cache_cfexampleapi_Asset_foo.foo"];
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

-(void)testClassComparison {
    BOOL result = CDAClassIsOfType([NSString class], [NSString class]);
    XCTAssertTrue(result);
}

-(void)testClassComparisonForSuperclass {
    BOOL result = CDAClassIsOfType([NSString class], [NSObject class]);
    XCTAssertTrue(result);
}

-(void)testCopyClient {
    CDAClient* client = [CDAClient new];
    client.resourceClassPrefix = @"YOLO";
    NSDictionary* dummyPayload = @{ @"sys": @{ @"id": @"06f5086772e0cd0b8f4e2381fa610d36" },
                                    @"name": @"yolo" };
    CDAContentType* dummyCT = [[CDAContentType alloc] initWithDictionary:dummyPayload client:self.client];
    [client registerClass:CDAEntry.class forContentType:dummyCT];

    CDASpace* space = [[CDASpace alloc] initWithDictionary:dummyPayload client:self.client];
    CDAClient* copiedClient = [client copyWithSpace:space];

    XCTAssertEqual(copiedClient.resourceClassPrefix, @"YOLO");
    XCTAssertEqual(copiedClient.space, space);
    XCTAssertTrue(copiedClient.contentTypeRegistry.hasCustomClasses);
}

-(void)testNoNetworkErrorCheck {
    NSError* someError = [NSError errorWithDomain:NSURLErrorDomain
                                             code:kCFURLErrorNotConnectedToInternet
                                         userInfo:nil];
    XCTAssert(CDAIsNoNetworkError(someError), @"");
}

-(void)testURLParameterParsing {
    NSURL* url = [NSURL URLWithString:@"https://cdn.contentful.com/spaces/cfexampleapi/entries?locale=%2A&sys.id=nyancat"];
    NSString* value = CDAValueForQueryParameter(url, @"locale");

    XCTAssertEqualObjects(value, @"*");
}

@end
