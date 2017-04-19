//
//  TestLocales.m
//  ManagementSDK
//
//  Created by Boris Bügling on 13/08/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <Keys/ManagementSDKKeys.h>
#import <ContentfulManagementAPI/ContentfulManagementAPI.h>
#import "CDAUtilities.h"
#import <VCRURLConnection/VCR.h>
#import "TestHelpers.h"

static NSString* randomLocaleCode() {
    NSString* randomString = CDASquashCharactersFromSetInString([NSCharacterSet decimalDigitCharacterSet],
                                                                [[NSUUID UUID] UUIDString]);
    return [NSString stringWithFormat:@"%@-%@",
            [randomString substringToIndex:2],
            [randomString substringFromIndex:randomString.length - 2]];
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


    VCRTest_it(@"can_be_created")
    
    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space createLocaleWithName:@"German"
                               code:randomLocaleCode()
                            success:^(CDAResponse *response, CMALocale *locale) {
                                expect(locale).toNot.beNil();
                                expect(locale.identifier).toNot.beNil();
                                expect(locale.name).to.equal(@"German");

                                done();
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
                               code:randomLocaleCode()
                            success:^(CDAResponse *response, CMALocale *locale) {
                                expect(locale).toNot.beNil();

                                locale.name = @"Not German";
                                [locale updateWithSuccess:^{
                                    expect(locale.name).to.equal(@"Not German");

                                    done();
                                } failure:^(CDAResponse *response, NSError *error) {
                                    XCTFail(@"Error: %@", error);

                                    done();
                                }];
                            } failure:^(CDAResponse *response, NSError *error) {
 
                                done();
                            }];
    });
    VCRTestEnd
});

SpecEnd
