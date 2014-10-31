//
//  RobustnessTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 31/10/14.
//
//

#import "CDAClient+Private.h"
#import "CDAContentTypeRegistry.h"
#import "CDAResponseSerializer.h"
#import "CDAResource+Private.h"
#import "ContentfulBaseTestCase.h"

@interface RobustnessTests : ContentfulBaseTestCase

@end

#pragma mark -

@implementation RobustnessTests

-(void)testCrash001 {
    CDAResponseSerializer* serializer = [[CDAResponseSerializer alloc] initWithClient:self.client];
    NSError* error;

    NSData* jsonData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:self.class] URLForResource:@"ContentType-001" withExtension:@"json" subdirectory:@"Fixtures"]];
    XCTAssertNotNil(jsonData);

    CDAContentType* contentType = [serializer responseObjectForResponse:nil data:jsonData error:&error];
    XCTAssertNotNil(contentType);
    [self.client.contentTypeRegistry addContentType:contentType];

    jsonData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:self.class] URLForResource:@"Crash-001" withExtension:@"json" subdirectory:@"Fixtures"]];
    XCTAssertNotNil(jsonData);
    
    CDAEntry* entry = [serializer responseObjectForResponse:nil data:jsonData error:&error];
    XCTAssertNotNil(entry);
}

@end