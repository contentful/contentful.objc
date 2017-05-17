//
//  TestSpaces.m
//  TestSpaces
//
//  Created by Boris Bügling on 07/14/2014.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <Keys/ContentfulSDKKeys.h>
#import <ContentfulManagementAPI/ContentfulManagementAPI.h>
#import <VCRURLConnection/VCR.h>
#import "TestHelpers.h"


SpecBegin(Spaces)

describe(@"CMA", ^{
    __block CMAClient* client;
    __block CMAOrganization* organization;

    beforeAll(^{
        setAsyncSpecTimeout(20.0);

        NSString *beforeEachTestName = @"fetch-space-before-each";
        [TestHelpers startRecordingOrLoadCassetteForTestNamed:beforeEachTestName
                                                     forClass:self.class];
        waitUntil(^(DoneCallback done) {
            NSString* token = [ContentfulSDKKeys new].managementAPIAccessToken;

            client = [[CMAClient alloc] initWithAccessToken:token];

            [client fetchOrganizationsWithSuccess:^(CDAResponse *response, CDAArray *array) {
                for (CMAOrganization* item in array.items) {
                    if ([item.identifier isEqualToString:@"1PLOOEmTI2S1NYald2TemO"]) {
                        organization = item;
                    }
                }

                done();
            } failure:^(CDAResponse *response, NSError *error) {
                XCTFail(@"Error: %@", error);
                
                done();
            }];
        });
        [TestHelpers endRecordingAndSaveWithName:beforeEachTestName
                                        forClass:self.class];
    });

    it(@"uses_the_correct_user-agent", ^{
        NSAssert(client, @"Client is not available.");
        CDARequest* request = [client fetchOrganizationsWithSuccess:^(CDAResponse* r, CDAArray* a){}
                                                            failure:^(CDAResponse* r, NSError* e){}];
        NSString* userAgent = request.request.allHTTPHeaderFields[@"User-Agent"];
        expect([userAgent hasPrefix:@"contentful-management.objc"]).to.beTruthy();
    });

    VCRTest_it(@"can_retrieve_all_Access_Tokens_of_Space")

    waitUntil(^(DoneCallback done) {
        NSAssert(client, @"Client is not available.");
        [client fetchSpaceWithIdentifier:@"hvjkfbzcwrfn" success:^(CDAResponse *response,
                                                                   CMASpace *space) {
            expect(space).toNot.beNil();

            [space fetchAccessTokensWithSuccess:^(CDAResponse* response, CDAArray* tokens) {
                expect(tokens).toNot.beNil();
                expect(tokens.items.count).equal(1);
                expect([tokens.items.firstObject token]).toNot.beNil();

                done();
            } failure:^(CDAResponse *response, NSError *error) {
                XCTFail(@"Error: %@", error);

                done();
            }];

            done();
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);

            done();
        }];
    });
    VCRTestEnd


    VCRTest_it(@"can_retrieve_all_Organizations_for_account")

    waitUntil(^(DoneCallback done) {
        NSAssert(client, @"Client is not available.");

        [client fetchOrganizationsWithSuccess:^(CDAResponse *response, CDAArray *array) {
            expect(array.items.count).equal(1);

            for (CMAOrganization* organization in array.items) {
                expect(organization.name).toNot.beNil();
                expect(organization.identifier).toNot.beNil();
                expect(organization.isActive).equal(YES);
                expect(organization.description).equal([NSString stringWithFormat:@"CMAOrganization %@ with name: %@", organization.identifier, organization.name]);
            }

            done();
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);

            done();
        }];
    });
    VCRTestEnd


    VCRTest_it(@"can_retrieve_all_Spaces_for_account")

    waitUntil(^(DoneCallback done) {
        NSAssert(client, @"Client is not available.");
        [client fetchAllSpacesWithSuccess:^(CDAResponse *response, CDAArray *array) {
            expect(response).toNot.beNil();

            expect(array).toNot.beNil();
            expect(array.items.count).to.equal(1);
            expect([array.items[0] class]).to.equal([CMASpace class]);

            done();
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);

            done();
        }];
    });
    VCRTestEnd

    VCRTest_it(@"can_retrieve_a_single_Space")
    waitUntil(^(DoneCallback done) {
        NSAssert(client, @"Client is not available.");
        [client fetchSpaceWithIdentifier:@"hvjkfbzcwrfn" success:^(CDAResponse *response,
                                                                   CMASpace *space) {
            expect(response).toNot.beNil();

            expect(space).toNot.beNil();
            expect(space.identifier).to.equal(@"hvjkfbzcwrfn");
            expect(space.name).to.equal(@"Obj-C CMA Test");

            done();
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);

            done();
        }];
    });
    VCRTestEnd

    VCRTest_it(@"can_create_new_Space")
    waitUntil(^(DoneCallback done) {
        NSAssert(client, @"Client is not available.");
        [client createSpaceWithName:@"MySpace"
                     inOrganization:organization
                            success:^(CDAResponse *response, CMASpace *space) {
                                expect(space).toNot.beNil();
                                expect(space.name).equal(@"MySpace");
                                expect(space.identifier).toNot.beNil();

                                [client fetchSpaceWithIdentifier:space.identifier
                                                         success:^(CDAResponse *response,
                                                                   CMASpace *newSpace) {
                                                             expect(newSpace).toNot.beNil();
                                                             expect(newSpace.name).equal(@"MySpace");

                                                             [space deleteWithSuccess:^{
                                                                 done();
                                                             } failure:^(CDAResponse *response,
                                                                         NSError *error) {
                                                                 XCTFail(@"Error: %@", error);

                                                                 done();
                                                             }];
                                                         } failure:^(CDAResponse *response,
                                                                     NSError *error) {
                                                             XCTFail(@"Error: %@", error);

                                                             done();
                                                         }];
                            } failure:^(CDAResponse *response, NSError *error) {
                                XCTFail(@"Error: %@", error);

                                done();
                            }];
    });
    VCRTestEnd

    VCRTest_it(@"can_delete_an_existing_Space")

    waitUntil(^(DoneCallback done) {
        NSAssert(client, @"Client is not available.");
        [client createSpaceWithName:@"MySpace   "
                     inOrganization:organization
                            success:^(CDAResponse *response, CMASpace *space) {
                                expect(space).toNot.beNil();

                                [space deleteWithSuccess:^{
                                    [client fetchSpaceWithIdentifier:space.identifier
                                                             success:^(CDAResponse *response,
                                                                       CMASpace *space) {
                                                                 XCTFail(@"Should not succeed.");

                                                                 done();
                                                             } failure:^(CDAResponse *response,
                                                                         NSError *error) {
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


    VCRTest_it(@"can_change_name_of_Space")

    waitUntil(^(DoneCallback done) {
        NSAssert(client, @"Client is not available.");
        [client fetchSpaceWithIdentifier:@"hvjkfbzcwrfn" success:^(CDAResponse *response,
                                                                   CMASpace *space) {
            expect(space).toNot.beNil();
            NSString* originalName = space.name;
            space.name = @"foo";

            [space updateWithSuccess:^{
                expect(space.name).to.equal(@"foo");

                space.name = originalName;

                [space updateWithSuccess:^{
                    expect(space.name).to.equal(originalName);

                    done();
                } failure:^(CDAResponse *response, NSError *error) {
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

    
    VCRTest_it(@"can_retrieve_user_associated_with_API_client")

    waitUntil(^(DoneCallback done) {
        NSAssert(client, @"Client is not available.");
        [client fetchUserWithSuccess:^(CDAResponse *response, CMAUser *user) {
            expect(user.firstName).to.equal(@"Ecosystem");
            expect(user.lastName).to.equal(@"Team");
            expect(user.avatarURL).to.equal([NSURL URLWithString:@"https://www.gravatar.com/avatar/807070085a93873004f24e0963467835?s=50&d=https%3A%2F%2Fstatic.contentful.com%2Fgatekeeper%2Fusers%2Fdefault-43783205a36955c723acfe0a32bcf72eebe709cac2067249bc80385b78ccc70d.png"]);
            
            done();
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);

            done();
        }];
    });
    VCRTestEnd
});

SpecEnd
