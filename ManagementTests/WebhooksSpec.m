//
//  TestWebhooks.m
//  ManagementSDK
//
//  Created by Boris Bügling on 22/12/15.
//  Copyright © 2015 Boris Bügling. All rights reserved.
//

#import <Keys/ManagementSDKKeys.h>
#import <ContentfulManagementAPI/ContentfulManagementAPI.h>
#import <VCRURLConnection/VCR.h>
#import "TestHelpers.h"


SpecBegin(Webhooks)

describe(@"Webhooks", ^{
    __block CMAClient* client;
    __block CMASpace* space;

    beforeAll(^{
        NSString *beforeEachTestName = @"fetch-space-before-each";
        [TestHelpers startRecordingOrLoadCassetteForTestNamed:beforeEachTestName
                                                     forClass:self.class];
        waitUntil(^(DoneCallback done) {
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
        });
        [TestHelpers endRecordingAndSaveWithName:beforeEachTestName
                                        forClass:self.class];
    });


    VCRTest_it(@"can_fetch_all_webhooks_for_space")

    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space fetchWebhooksWithSuccess:^(CDAResponse* response, CDAArray* array) {
            XCTAssertEqual(array.items.count, 1);

            done();
        } failure:^(CDAResponse* response, NSError* error) {
            XCTFail("Error: %@", error);

            done();
        }];
    });
    VCRTestEnd


    VCRTest_it(@"can_create_and_delete_webhooks")

    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");

        NSString* name = @"yolo";
        NSURL* url = [NSURL URLWithString:@"http://example.com/example"];

        [space createWebhookWithName:name
                                 url:url
                              topics:nil
                             headers:nil
                   httpBasicUsername:nil
                   httpBasicPassword:nil
                             success:^(CDAResponse* response, CMAWebhook* webhook) {
                                 XCTAssertNotNil(webhook);
                                 XCTAssertEqualObjects(webhook.name, name);
                                 XCTAssertEqualObjects(webhook.url, url);
                                 XCTAssertEqualObjects(webhook.topics, @[ @"*.*" ]);
                                 XCTAssertEqualObjects(webhook.headers, @{});
                                 XCTAssertNil(webhook.httpBasicUsername);
                                 XCTAssertNil(webhook.httpBasicPassword);

                                 [webhook deleteWithSuccess:^{
                                     done();
                                 } failure:^(CDAResponse * _Nullable response, NSError * _Nonnull error) {
                                     XCTFail("Error: %@", error);
                                     done();
                                 }];
                                 done();
                             } failure:^(CDAResponse* response, NSError* error) {
                                 XCTFail("Error: %@", error);

                                 done();
                             }];
    });
    VCRTestEnd


    VCRTest_it(@"can_fetch_single_webhook")

    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space fetchWebhookWithIdentifier:@"3ylg2m4MZEnhggGFyI0gyJ"
                                  success:^(CDAResponse* response, CMAWebhook* webhook) {
                                      XCTAssertNotNil(webhook);
                                      XCTAssertEqualObjects(webhook.name, @"yolo");
                                      XCTAssertEqualObjects(webhook.url, [NSURL URLWithString:@"http://example.com/"]);
                                      XCTAssertEqualObjects(webhook.topics, (@[ @"Entry.archive" ]));
                                      expect([webhook.headers isEqualToDictionary:@{ @"moo": @"foo",  @"foo": @"bar" }]);
                                      XCTAssertEqualObjects(webhook.httpBasicUsername, @"yolo");

                                      done();
                                  } failure:^(CDAResponse* response, NSError* error) {
                                      XCTFail("Error: %@", error);

                                      done();
                                  }];
    });
    VCRTestEnd


    // This test hits the same fetch endpoint twice, so we must use different recordings
    // and regular spec style test declaration.
    it(@"can_update_single_webhook", ^{

        NSString *webhookId = @"3ylg2m4MZEnhggGFyI0gyJ";
        NSString *newWebhookName = @"updated name";
        NSString *originalWebhookName = @"yolo";

        NSString *updateWebhookTestName = @"can_successfully_update_webhook";
        [TestHelpers startRecordingOrLoadCassetteForTestNamed:updateWebhookTestName
                                                     forClass:self.class];

        waitUntil(^(DoneCallback done) {
            NSAssert(space, @"Test space could not be found.");
            [space fetchWebhookWithIdentifier:webhookId
                                      success:^(CDAResponse* response, CMAWebhook* webhook) {
                                          XCTAssertNotNil(webhook);
                                          XCTAssertEqualObjects(webhook.name, originalWebhookName);

                                          webhook.name = newWebhookName;

                                          [webhook updateWithSuccess:^{
                                              if (![VCR isReplaying]) {
                                                  [NSThread sleepForTimeInterval:3.0];
                                              }
                                              done();

                                          } failure:^(CDAResponse* r, NSError* e) {
                                              XCTFail("Error: %@", e);
                                              
                                              done();
                                          }];
                                      } failure:^(CDAResponse* response, NSError* error) {
                                          XCTFail("Error: %@", error);
                                          
                                          done();
                                      }];
        });
        [TestHelpers endRecordingAndSaveWithName:updateWebhookTestName
                                        forClass:self.class];

        NSString *updatedWebhookCorrectlyTestName = @"updated_webhook_has_correct_description";
        [TestHelpers startRecordingOrLoadCassetteForTestNamed:updatedWebhookCorrectlyTestName
                                                     forClass:self.class];
        waitUntil(^(DoneCallback done) {

        [space fetchWebhookWithIdentifier:webhookId
                                  success:^(CDAResponse* r, CMAWebhook* webhook) {
                                      XCTAssertNotNil(webhook);
                                      XCTAssertEqualObjects(webhook.name, newWebhookName);

                                      webhook.name = originalWebhookName;

                                      [webhook updateWithSuccess:^{
                                          done();
                                      } failure:^(CDAResponse * _Nullable response, NSError * _Nonnull error) {
                                          XCTFail("Error: %@", error);
                                          done();
                                      }];
                                  } failure:^(CDAResponse* r, NSError* e) {
                                      XCTFail("Error: %@", e);

                                      done();
                                  }];
        });
        [TestHelpers endRecordingAndSaveWithName:updatedWebhookCorrectlyTestName
                                        forClass:self.class];

    });

});

SpecEnd

