//
//  UtilityTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 28/03/14.
//
//

#import <XCTest/XCTest.h>

#import "CDAFallbackDictionary.h"

@interface UtilityTests : XCTestCase

@end

#pragma mark -

@implementation UtilityTests

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

@end
