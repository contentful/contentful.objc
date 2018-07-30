//
//  ContentfulBaseTestCase.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 06/03/14.
//
//

@import XCTest;

#import <CCLRequestReplay/CCLRequestJSONRecording.h>
#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>

@interface ContentfulBaseTestCase : XCTestCase

@property (nonatomic) CDAClient* client;

- (void)addRecordingWithJSONNamed:(NSString*)JSONName
                      inDirectory:(NSString*)directory
                          matcher:(CCLURLRequestMatcher)matcher;
- (void)addResponseWithData:(NSData*)data
                 statusCode:(NSInteger)statusCode
                    headers:(NSDictionary*)headers
                    matcher:(CCLURLRequestMatcher)matcher;
- (void)addResponseWithError:(NSError*)error matcher:(CCLURLRequestMatcher)matcher;
- (void)assertField:(CDAField*)field
      hasIdentifier:(NSString*)identifier
               name:(NSString*)name
               type:(CDAFieldType)type;
- (CDAEntry*)customEntryHelperWithFields:(NSDictionary*)fields;
- (void)removeAllStubs;
- (void)setUpCCLRequestReplayForNSURLSession;
- (void)stubHTTPRequestUsingFixtures:(NSDictionary*)fixtureMap inDirectory:(NSString*)directoryName;

@end
