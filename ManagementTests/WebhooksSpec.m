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
            XCTAssertEqual(array.items.count, 2);

            done();
        } failure:^(CDAResponse* response, NSError* error) {
            XCTFail("Error: %@", error);

            done();
        }];
    });
    VCRTestEnd


    VCRTest_it(@"can_create_new_webhook")

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
                                      XCTAssertEqualObjects(webhook.headers, (@{ @"foo": @"bar", @"moo": @"foo" }));
                                      XCTAssertEqualObjects(webhook.httpBasicUsername, @"yolo");

                                      done();
                                  } failure:^(CDAResponse* response, NSError* error) {
                                      XCTFail("Error: %@", error);

                                      done();
                                  }];
    });
    VCRTestEnd

    VCRTest_it(@"can_update_single_webhook")

    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space fetchWebhookWithIdentifier:@"3ylg2m4MZEnhggGFyI0gyJ"
                                  success:^(CDAResponse* response, CMAWebhook* webhook) {
                                      XCTAssertNotNil(webhook);
                                      XCTAssertEqualObjects(webhook.name, @"yolo");

                                      webhook.name = @"updated name";
                                      [webhook updateWithSuccess:^{
                                          [space fetchWebhookWithIdentifier:@"3ylg2m4MZEnhggGFyI0gyJ"
                                                                    success:^(CDAResponse* r, CMAWebhook* webhook) {
                                                                        XCTAssertNotNil(webhook);
                                                                        XCTAssertEqualObjects(webhook.name, @"updated name");

                                                                        done();
                                                                    } failure:^(CDAResponse* r, NSError* e) {
                                                                        XCTFail("Error: %@", e);

                                                                        done();
                                                                    }];
                                      } failure:^(CDAResponse* r, NSError* e) {
                                          XCTFail("Error: %@", e);

                                          done();
                                      }];
                                  } failure:^(CDAResponse* response, NSError* error) {
                                      XCTFail("Error: %@", error);

                                      done();
                                  }];
    });
    VCRTestEnd


    VCRTest_it(@"can_delete_single-webhook")

    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space fetchWebhookWithIdentifier:@"4uUpDd5MecwQN8y6DmTXiF"
                                  success:^(CDAResponse* response, CMAWebhook* webhook) {
                                      [webhook deleteWithSuccess:^{
                                          [space fetchWebhookWithIdentifier:@"4uUpDd5MecwQN8y6DmTXiF" success:^(CDAResponse* response, CMAWebhook* webhook) {
                                              XCTFail(@"Webhook shouldn't exist.");

                                              done();
                                          } failure:^(CDAResponse* response, NSError* error) {
                                              done();
                                          }];
                                      } failure:^(CDAResponse* response, NSError* error) {
                                          XCTFail("Error: %@", error);

                                          done();
                                      }];
                                  } failure:^(CDAResponse* response, NSError* error) {
                                      XCTFail("Error: %@", error);

                                      done();
                                  }];
    });
    VCRTestEnd
});

SpecEnd

