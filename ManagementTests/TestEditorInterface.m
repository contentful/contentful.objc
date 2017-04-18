//
//  TestEditorInterface.m
//  ManagementSDK
//
//  Created by Boris Bügling on 22/12/15.
//  Copyright © 2015 Boris Bügling. All rights reserved.
//

@import XCTest;
#import <Specta/Specta.h>

#import <Keys/ManagementSDKKeys.h>
#import <ContentfulManagementAPI/ContentfulManagementAPI.h>

#import "BBURecordingHelper.h"

/*
 The spec name is a result of the test recordings being essential to a working testsuite right now
 and the recordings are order dependant.
 */
SpecBegin(XXX)

describe(@"EditorInterface", ^{
    __block CMAClient* client;
    __block CMASpace* space;

    RECORD_TESTCASE

    beforeEach(^{ waitUntil(^(DoneCallback done) {
        NSString* token = [ManagementSDKKeys new].managementAPIAccessToken;

        client = [[CMAClient alloc] initWithAccessToken:token];

        [client fetchSpaceWithIdentifier:@"hvjkfbzcwrfn"
                                 success:^(CDAResponse *response, CMASpace *mySpace) {
                                     expect(mySpace).toNot.beNil();
                                     space = mySpace;

                                     done();
                                 } failure:^(CDAResponse *response, NSError *error) {
                                     XCTFail(@"Error: %@", error);

                                     done();
                                 }];
    }); });

    it(@"can fetch editor interface", ^{ waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space fetchContentTypeWithIdentifier:@"3G3PM4Uth6Q4ymGG8iiasI"
                                      success:^(CDAResponse* response, CMAContentType* contentType) {
                                          [contentType fetchEditorInterfaceWithSuccess:^(CDAResponse*  response, CMAEditorInterface* interface) {
                                              XCTAssertNotNil(contentType);
                                              XCTAssertNotNil(interface);
                                              XCTAssertNotNil(interface.controls);

                                              done();
                                          } failure:^(CDAResponse* response, NSError* error) {
                                              XCTFail("Error: %@", error);

                                              done();
                                          }];
                                      } failure:^(CDAResponse* response, NSError* error) {
                                          XCTFail("Error: %@", error);

                                          done();
                                      }];
    }); });

    it(@"can update editor interface", ^{ waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space fetchContentTypeWithIdentifier:@"3G3PM4Uth6Q4ymGG8iiasI"
                                      success:^(CDAResponse* response, CMAContentType* contentType) {
                                          [contentType fetchEditorInterfaceWithSuccess:^(CDAResponse*  response, CMAEditorInterface* interface) {
                                              XCTAssertNotNil(contentType);

                                              NSMutableArray* controls = [interface.controls mutableCopy];

                                              [controls enumerateObjectsUsingBlock:^(NSDictionary* item,
                                                                                     NSUInteger idx,
                                                                                     BOOL *stop) {
                                                  if ([item[@"fieldId"] isEqualToString:@"title"]) {
                                                      [controls removeObjectAtIndex:idx];
                                                      *stop = YES;
                                                  }
                                              }];

                                              [controls addObject:@{ @"fieldId": @"title",
                                                                     @"widgetId": @"multipleLine" }];
                                              interface.controls = controls;

                                              [interface updateWithSuccess:^{
                                                  done();
                                              } failure:^(CDAResponse* response, NSError* error) {
                                                  /* FIXME: Replaying issue with this test, so we skip
                                                   the verification step here for now. */
                                                  if (![BBURecordingHelper sharedHelper].isReplaying) {
                                                      XCTFail("Error: %@", error);
                                                  }

                                                  done();
                                              }];

                                              done();
                                          } failure:^(CDAResponse* response, NSError* error) {
                                              XCTFail("Error: %@", error);

                                              done();
                                          }];
                                      } failure:^(CDAResponse* response, NSError* error) {
                                          XCTFail("Error: %@", error);
                                          
                                          done();
                                      }];
    }); });
});

SpecEnd

