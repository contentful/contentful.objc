//
//  BBURecordingHelper.m
//  ManagementSDK
//
//  Created by Boris Bügling on 30/07/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import "BBURecordingHelper.h"
#import <CCLRequestReplay/CCLRequestJSONRecording.h>
#import <CCLRequestReplay/CCLRequestRecordProtocol.h>
#import <CCLRequestReplay/CCLRequestReplayProtocol.h>
#import <ContentfulManagementAPI/ContentfulManagementAPI.h>


#import "CDAClient+Private.h"
#import "CDARequestOperationManager.h"
#import "CDAResource+Private.h"


@interface BBURecordingHelper ()

@property (nonatomic) CCLRequestReplayManager* manager;
@property (nonatomic, getter = isReplaying) BOOL replaying;

@end


#pragma mark -

@implementation BBURecordingHelper

+(instancetype)sharedHelper {
    static BBURecordingHelper *sharedHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHelper = [self new];
    });
    return sharedHelper;
}

#pragma mark -

/*
 CCLRequestReplay doesn't contain support for NSURLSession by default, so we need to add its URL
 protocols manually to the session used by CDAClient
 */

+ (void)setUpCCLRequestReplayForNSURLSessionWithCDAClient:(CDAClient*)client {

    NSURLSessionConfiguration* config = client.requestOperationManager.session.configuration;

    NSMutableArray* protocolClasses = [config.protocolClasses mutableCopy];
    [protocolClasses insertObject:[CCLRequestRecordProtocol class] atIndex:0];
    [protocolClasses insertObject:[CCLRequestReplayProtocol class] atIndex:0];
    config.protocolClasses = protocolClasses;

    NSURLSession *newSession = [NSURLSession sessionWithConfiguration:config
                                                             delegate:client.requestOperationManager
                                                        delegateQueue:client.requestOperationManager.operationQueue];
    
    [client.requestOperationManager setValue:newSession forKey:@"session"];
}

-(void)loadRecordingsForTestCase:(Class)testCase {
    NSBundle* bundle = [NSBundle bundleForClass:testCase];
    NSString* recordingPath = [bundle pathForResource:NSStringFromClass(testCase)
                                               ofType:@"recording"
                                          inDirectory:@"Recordings"];

    if ([[NSFileManager defaultManager] fileExistsAtPath:recordingPath]) {
        self.manager = [NSKeyedUnarchiver unarchiveObjectWithFile:recordingPath];
        self.replaying = YES;

        CCLRequestJSONRecording* recording = [[CCLRequestJSONRecording alloc]
                                              initWithBundledJSONNamed:nil
                                              inDirectory:nil
                                              matcher:^BOOL(NSURLRequest *request) {
                                                  return YES;
                                              }
                                              statusCode:200
                                              headerFields:nil];
        [self.manager addRecording:recording];

        [self.manager replay];
    } else {
        self.manager = [CCLRequestReplayManager new];
        self.replaying = NO;
        
        [self.manager record];
    }
}

-(void)storeRecordingsForTestCase:(Class)testCase {
    [self.manager stopReplay];
    [self.manager stopRecording];

    NSString* recordingName = [NSStringFromClass(testCase) stringByAppendingPathExtension:@"recording"];
    NSString* path = [NSTemporaryDirectory() stringByAppendingPathComponent:recordingName];
    BOOL result = [NSKeyedArchiver archiveRootObject:self.manager
                                              toFile:path];

    if (!result) {
        [NSException raise:NSInternalInconsistencyException format:@"Recording %@ could not be stored",
         path];
    }

    self.manager = nil;
}

@end
