//
//  TestLocales.m
//  ManagementSDK
//
//  Created by Boris Bügling on 13/08/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <Keys/ContentfulSDKKeys.h>
#import <ContentfulManagementAPI/ContentfulManagementAPI.h>
#import <VCRURLConnection/VCR.h>
#import "TestHelpers.h"

static NSString* testLocaleCode() {
    return @"my-EN";
}

SpecBegin(Locale)

describe(@"Locale", ^{
    __block CMAClient* client;
    __block CMASpace* space;

    beforeAll(^{
        NSString *beforeEachTestName = @"fetch-space-before-each";
        [TestHelpers startRecordingOrLoadCassetteForTestNamed:beforeEachTestName
                                                     forClass:self.class];
        waitUntil(^(DoneCallback done) {
            NSString* token = [ContentfulSDKKeys new].managementAPIAccessToken;

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


    VCRTest_it(@"can_be_created_and_deleted")
    
    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");

        [space createLocaleWithName:@"German"
                               code:testLocaleCode()
                            success:^(CDAResponse *response, CMALocale *locale) {

                                expect(locale).toNot.beNil();
                                expect(locale.identifier).toNot.beNil();
                                expect(locale.name).to.equal(@"German");

                                [locale deleteWithSuccess:^{

                                    done();
                                } failure:^(CDAResponse * _Nullable response, NSError * _Nonnull error) {
                                    XCTFail(@"Error: %@", error);
                                    done();
                                }];
                            } failure:^(CDAResponse *response, NSError *error) {
                                XCTFail(@"Error: %@", error);
                                done();
                            }];
    });
    VCRTestEnd


    VCRTest_it(@"can_be_updated")

    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");

        [space createLocaleWithName:@"German"
                               code:testLocaleCode()
                            success:^(CDAResponse *response, CMALocale *locale) {

                                expect(locale).toNot.beNil();

                                locale.name = @"Not German";
                                [locale updateWithSuccess:^{
                                    expect(locale.name).to.equal(@"Not German");

                                    [locale deleteWithSuccess:^{

                                        done();
                                    } failure:^(CDAResponse * _Nullable response, NSError * _Nonnull error) {
                                        XCTFail(@"Error: %@", error);
                                        done();
                                    }];
                                } failure:^(CDAResponse *response, NSError *error) {
                                    XCTFail(@"Error: %@", error);

                                    done();
                                }];
                            } failure:^(CDAResponse *response, NSError *error) {
                                XCTFail(@"Error: %@", error);

                                done();
                            }];
    });
    VCRTestEnd
});

SpecEnd
