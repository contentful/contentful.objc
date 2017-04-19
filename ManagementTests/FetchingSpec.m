//
//  FetchingSpec.m
//  ManagementSDK
//
//  Created by Boris Bügling on 03/12/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//


#import <Keys/ManagementSDKKeys.h>
#import <ContentfulManagementAPI/ContentfulManagementAPI.h>
#import <VCRURLConnection/VCR.h>
#import "TestHelpers.h"

SpecBegin(Fetching)

describe(@"Space", ^{
    __block CMASpace* space;

    beforeAll(^{ waitUntil(^(DoneCallback done) {


        NSString *beforeEachTestName = @"fetch-space-before-each";
        [TestHelpers startRecordingOrLoadCassetteForTestNamed:beforeEachTestName
                                                     forClass:self.class];

        NSString* token = [ManagementSDKKeys new].managementAPIAccessToken;

        CMAClient* client = [[CMAClient alloc] initWithAccessToken:token];

        [client fetchSpaceWithIdentifier:@"hvjkfbzcwrfn" success:^(CDAResponse *response,
                                                                   CMASpace *retrievedSpace) {
            expect(client).toNot.beNil();
            expect(retrievedSpace).toNot.beNil();

            space = retrievedSpace;

            done();
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);

            done();
        }];
    }); });

    it(@"can_retrieve_all_locales_of_a_Space", ^{
        NSAssert(space, @"Test space could not be found.");

        expect(space.locales.count).to.beGreaterThanOrEqualTo(1);
        expect(space.defaultLocale).to.equal(@"en-US");

        NSDictionary* engrish = nil;

        for (NSDictionary* locale in space.locales) {
            if ([locale[@"code"] isEqualToString:@"en-US"]) {
                engrish = locale;
                break;
            }
        }

        expect(engrish).toNot.beNil();
        expect(engrish[@"name"]).to.equal(@"U.S. English");
    });


    VCRTest_it(@"can_retrieve_all_Assets_from_Space")

    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space fetchAssetsWithSuccess:^(CDAResponse *response, CDAArray *array) {
            expect(array).toNot.beNil();
            expect(array.items.count).to.beGreaterThan(0);

            done();
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);

            done();
        }];
    });
    VCRTestEnd


    VCRTest_it(@"can_retrieve_Assets_matching_query")

    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space fetchAssetsMatching:@{ @"order": @"-sys.updatedAt" }
                           success:^(CDAResponse *response, CDAArray *array) {
                               expect(array).toNot.beNil();
                               expect(array.items.count).to.beGreaterThan(0);

                               done();
                           } failure:^(CDAResponse *response, NSError *error) {
                               XCTFail(@"Error: %@", error);
                               
                               done();
                           }];
    });
    VCRTestEnd

    VCRTest_it(@"can_retrieve_single_ContentType_from_Space")
        waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space fetchContentTypeWithIdentifier:@"6FxqhReTPUuYAYW8gqOwS"
                                      success:^(CDAResponse *response, CMAContentType *contentType) {
                                          expect(contentType).toNot.beNil();

                                          done();
                                      } failure:^(CDAResponse *response, NSError *error) {
                                          XCTFail(@"Error: %@", error);

                                          done();
                                      }];
    });
    VCRTestEnd


    VCRTest_it(@"can_retrieve_ContentTypes_of_Space")
    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space fetchContentTypesWithSuccess:^(CDAResponse *response, CDAArray *array) {
            expect(array).toNot.beNil();
            expect(array.items.count).equal(68);
            expect([array.items[0] identifier]).toNot.beNil();

            done();
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);

            done();
        }];
    });
    VCRTestEnd

    VCRTest_it(@"can_retrieve_all_Entries_from_Space")

    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space fetchEntriesWithSuccess:^(CDAResponse *response, CDAArray *array) {
            expect(array).toNot.beNil();
            expect(array.items.count).to.beGreaterThan(0);

            done();
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);

            done();
        }];
    });
    VCRTestEnd

    VCRTest_it(@"can_retrieve_Entries_matching_query")
        waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space fetchEntriesMatching:@{ @"order": @"-sys.updatedAt" }
                            success:^(CDAResponse *response, CDAArray *array) {
                                expect(array).toNot.beNil();
                                expect(array.items.count).to.beGreaterThan(0);

                                done();
                            } failure:^(CDAResponse *response, NSError *error) {
                                XCTFail(@"Error: %@", error);

                                done();
                            }];
    });
    VCRTestEnd
});

SpecEnd
