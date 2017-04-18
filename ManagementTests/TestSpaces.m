//
//  TestSpaces.m
//  TestSpaces
//
//  Created by Boris Bügling on 07/14/2014.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <Keys/ManagementSDKKeys.h>
#import <ContentfulManagementAPI/ContentfulManagementAPI.h>

#import "BBURecordingHelper.h"

SpecBegin(Spaces)

describe(@"CMA", ^{
    __block CMAClient* client;
    __block CMAOrganization* organization;

    RECORD_TESTCASE

    beforeEach(^{
        setAsyncSpecTimeout(20.0);

        waitUntil(^(DoneCallback done) {
            NSString* token = [ManagementSDKKeys new].managementAPIAccessToken;

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
    }); });

    it(@"uses the correct user-agent", ^{
        NSAssert(client, @"Client is not available.");
        CDARequest* request = [client fetchOrganizationsWithSuccess:^(CDAResponse* r, CDAArray* a){}
                                                            failure:^(CDAResponse* r, NSError* e){}];
        NSString* userAgent = request.request.allHTTPHeaderFields[@"User-Agent"];
        expect([userAgent hasPrefix:@"contentful-management.objc"]).to.beTruthy();
    });

    it(@"can retrieve all Access Tokens of a Space", ^{ waitUntil(^(DoneCallback done) {
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
    }); });

    it(@"can retrieve all Organizations of an account", ^{ waitUntil(^(DoneCallback done) {
        NSAssert(client, @"Client is not available.");
        [client fetchOrganizationsWithSuccess:^(CDAResponse *response, CDAArray *array) {
            expect(array.items.count).equal(7);

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
    }); });

    it(@"can retrieve all Spaces of an account", ^{ waitUntil(^(DoneCallback done) {
        NSAssert(client, @"Client is not available.");
        [client fetchAllSpacesWithSuccess:^(CDAResponse *response, CDAArray *array) {
            expect(response).toNot.beNil();

            expect(array).toNot.beNil();
            expect(array.items.count).to.equal(52);
            expect([array.items[0] class]).to.equal([CMASpace class]);

            done();
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);

            done();
        }];
    }); });

    it(@"can retrieve a single Space", ^{ waitUntil(^(DoneCallback done) {
        NSAssert(client, @"Client is not available.");
        [client fetchSpaceWithIdentifier:@"hvjkfbzcwrfn" success:^(CDAResponse *response,
                                                                   CMASpace *space) {
            expect(response).toNot.beNil();

            expect(space).toNot.beNil();
            expect(space.identifier).to.equal(@"hvjkfbzcwrfn");
            expect(space.name).to.equal(@"CMA SDK Test");

            done();
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);

            done();
        }];
    }); });

    it(@"can create a new Space", ^{ waitUntil(^(DoneCallback done) {
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
    }); });

    it(@"can create a new Space within a specific Organization", ^{ waitUntil(^(DoneCallback done) {
        expect(organization).toNot.beNil;

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
    }); });

    it(@"can delete an existing Space", ^{ waitUntil(^(DoneCallback done) {
        NSAssert(client, @"Client is not available.");
        [client createSpaceWithName:@"MySpace"
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
    }); });

    it(@"can change the name of a Space", ^{ waitUntil(^(DoneCallback done) {
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
    }); });

    it(@"can retrieve the user associated with the API client", ^{ waitUntil(^(DoneCallback done) {
        NSAssert(client, @"Client is not available.");
        [client fetchUserWithSuccess:^(CDAResponse *response, CMAUser *user) {
            expect(user.firstName).to.equal(@"Boris");
            expect(user.lastName).to.equal(@"Bügling");
            expect(user.avatarURL).to.equal([NSURL URLWithString:@"https://www.gravatar.com/avatar/66d863ad05a1af75a0e3c5cedc816943?s=50&d=https%3A%2F%2Fstatic.contentful.com%2Fgatekeeper%2Fusers%2Fdefault-f100256c71c0b6b409ec3c4959841976.png"]);
            
            done();
        } failure:^(CDAResponse *response, NSError *error) {
            XCTFail(@"Error: %@", error);

            done();
        }];
    }); });
});

SpecEnd
