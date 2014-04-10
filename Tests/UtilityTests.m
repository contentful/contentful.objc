//
//  UtilityTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 28/03/14.
//
//

#import <XCTest/XCTest.h>

#import "CDAFallbackDictionary.h"
#import "CDAResource+Private.h"
#import "CDAUtilities.h"

@interface UtilityTests : XCTestCase

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
    NSString* cacheFileName = CDACacheFileNameForQuery(CDAResourceTypeAsset, @{ @"foo": @"bar" });
    [self assertCacheFile:cacheFileName againstSuffix:@"com.contentful.sdk/cache_0_{foo=bar;}.data"];
}

-(void)testCacheFileNameForResource {
    CDAResource* resource = [CDAResource resourceObjectForDictionary:@{ @"sys": @{ @"id": @"foo", @"type": @"Asset" } } client:[CDAClient new]];
    NSString* cacheFileName = CDACacheFileNameForResource(resource);
    [self assertCacheFile:cacheFileName againstSuffix:@"com.contentful.sdk/cache_Asset_foo.data"];
}

-(void)testNoNetworkErrorCheck {
    NSError* someError = [NSError errorWithDomain:NSURLErrorDomain
                                             code:kCFURLErrorNotConnectedToInternet
                                         userInfo:nil];
    XCTAssert(CDAIsNoNetworkError(someError), @"");
}

@end
