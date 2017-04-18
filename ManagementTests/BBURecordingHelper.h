//
//  BBURecordingHelper.h
//  ManagementSDK
//
//  Created by Boris Bügling on 30/07/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ContentfulManagementAPI/CMAClient.h>

@class CDAClient;

#define RECORD_TESTCASE     beforeAll(^{ \
[[BBURecordingHelper sharedHelper] loadRecordingsForTestCase:[self class]]; \
}); \
\
afterAll(^{ \
[[BBURecordingHelper sharedHelper] storeRecordingsForTestCase:[self class]]; \
});

@interface CMAClient (TestPrivate)
@property (nonatomic) CDAClient* client;
@end

@interface CDAResource (TestPrivate)
@property (nonatomic) CDAClient *client;
@end





@interface BBURecordingHelper : NSObject

+(instancetype)sharedHelper;

@property (nonatomic, readonly, getter = isReplaying) BOOL replaying;

-(void)loadRecordingsForTestCase:(Class)testCase;
-(void)storeRecordingsForTestCase:(Class)testCase;

+(void)setUpCCLRequestReplayForNSURLSessionWithCDAClient:(CDAClient*)client;

@end
