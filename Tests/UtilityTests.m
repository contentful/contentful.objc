//
//  UtilityTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 28/03/14.
//
//

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

-(void)testNoNetworkErrorCheck {
    NSError* someError = [NSError errorWithDomain:NSURLErrorDomain
                                             code:kCFURLErrorNotConnectedToInternet
                                         userInfo:nil];
    XCTAssert(CDAIsNoNetworkError(someError), @"");
}

@end
