//
//  PublishedSpec.m
//  ManagementSDK
//
//  Created by Boris Bügling on 22/12/15.
//  Copyright © 2015 Boris Bügling. All rights reserved.
//

#import <Keys/ManagementSDKKeys.h>
#import <ContentfulManagementAPI/ContentfulManagementAPI.h>
#import <VCRURLConnection/VCR.h>
#import "TestHelpers.h"


SpecBegin(Published)

describe(@"Published", ^{
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
    

    VCRTest_it(@"can_fetch_published_content_types")
    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space fetchPublishedContentTypesWithSuccess:^(CDAResponse *response, CDAArray *array) {
            XCTAssertEqual(array.items.count, 4);

            done();
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail("Error: %@", error);

            done();
        }];
    });
    VCRTestEnd
});

SpecEnd

