//
//  TestFetching.m
//  ManagementSDK
//
//  Created by Boris Bügling on 03/12/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//


#import <Keys/ManagementSDKKeys.h>
#import <ContentfulManagementAPI/ContentfulManagementAPI.h>

#import "BBURecordingHelper.h"

SpecBegin(Fetching)

describe(@"Space", ^{
    __block CMASpace* space;

    RECORD_TESTCASE

    beforeEach(^{ waitUntil(^(DoneCallback done) {
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

    it(@"can retrieve all locales of a Space", ^{
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

    it(@"can retrieve all Assets from a Space", ^{ waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space fetchAssetsWithSuccess:^(CDAResponse *response, CDAArray *array) {
            expect(array).toNot.beNil();
            expect(array.items.count).to.beGreaterThan(0);

            done();
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);

            done();
        }];
    }); });

    it(@"can retrieve Assets matching a query", ^{ waitUntil(^(DoneCallback done) {
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
    }); });

    it(@"can retrieve a single Content Type from a Space", ^{ waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space fetchContentTypeWithIdentifier:@"6FxqhReTPUuYAYW8gqOwS"
                                      success:^(CDAResponse *response, CMAContentType *contentType) {
                                          expect(contentType).toNot.beNil();

                                          done();
                                      } failure:^(CDAResponse *response, NSError *error) {
                                          XCTFail(@"Error: %@", error);

                                          done();
                                      }];
    }); });

    it(@"can retrieve the Content Types of a Space", ^{ waitUntil(^(DoneCallback done) {
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
    }); });

    it(@"can retrieve all Entries from a Space", ^{ waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space fetchEntriesWithSuccess:^(CDAResponse *response, CDAArray *array) {
            expect(array).toNot.beNil();
            expect(array.items.count).to.beGreaterThan(0);

            done();
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);

            done();
        }];
    }); });

    it(@"can retrieve Entries matching a query", ^{ waitUntil(^(DoneCallback done) {
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
    }); });
});

SpecEnd
