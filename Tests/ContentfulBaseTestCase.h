//
//  ContentfulBaseTestCase.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 06/03/14.
//
//

#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>
#import <FBSnapshotTestCase/FBSnapshotTestController.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <XCTest/XCTest.h>

#import "AsyncTesting.h"

@interface ContentfulBaseTestCase : XCTestCase

@property (nonatomic) CDAClient* client;
@property (nonatomic, readonly) FBSnapshotTestController* snapshotTestController;

- (void)assertField:(CDAField*)field
      hasIdentifier:(NSString*)identifier
               name:(NSString*)name
               type:(CDAFieldType)type;
- (void)compareImage:(UIImage*)image forTestSelector:(SEL)testSelector;
- (CDAEntry*)customEntryHelperWithFields:(NSDictionary*)fields;
- (OHHTTPStubsResponse*)responseWithBundledJSONNamed:(NSString*)JSONName inDirectory:(NSString*)directoryName;
- (void)stubHTTPRequestUsingFixtures:(NSDictionary*)fixtureMap inDirectory:(NSString*)directoryName;

@end
