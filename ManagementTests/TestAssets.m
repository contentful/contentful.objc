//
//  TestAssets.m
//  ManagementSDK
//
//  Created by Boris Bügling on 28/07/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <Keys/ManagementSDKKeys.h>
#import <ContentfulManagementAPI/ContentfulManagementAPI.h>

#import "BBURecordingHelper.h"
#import "CMASpace+Private.h"

SpecBegin(Asset)

describe(@"Asset", ^{
    __block CMAClient* client; 
    __block CMASpace* space;

//    RECORD_TESTCASE

    afterAll(^{
        [[BBURecordingHelper sharedHelper] storeRecordingsForTestCase:[self class]];
    });

    beforeEach(^{ waitUntil(^(DoneCallback done) {
        NSString* token = [ManagementSDKKeys new].managementAPIAccessToken;

        client = [[CMAClient alloc] initWithAccessToken:token];
        [BBURecordingHelper setUpCCLRequestReplayForNSURLSessionWithCDAClient:client.client];
        [[BBURecordingHelper sharedHelper] loadRecordingsForTestCase:[self class]];

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

    it(@"can be archived", ^{ waitUntil(^(DoneCallback done) {

        NSAssert(space, @"Test space could not be found.");
        [BBURecordingHelper setUpCCLRequestReplayForNSURLSessionWithCDAClient:space.client];
        [[BBURecordingHelper sharedHelper] loadRecordingsForTestCase:[self class]];

        [space createAssetWithTitle:nil
                        description:nil
                       fileToUpload:nil
                            success:^(CDAResponse *response, CMAAsset *asset) {
                                expect(asset).toNot.beNil();
                                expect(asset.isArchived).to.beFalsy();

                                [asset archiveWithSuccess:^{
                                    expect(asset.sys[@"archivedVersion"]).equal(@1);
                                    expect(asset.isArchived).to.beTruthy();

                                    done();
                                } failure:^(CDAResponse *response, NSError *error) {
                                    XCTFail(@"Error: %@", error);

                                    done();
                                }];
                            } failure:^(CDAResponse *response, NSError *error) {
                                XCTFail(@"Error: %@", error);
                                
                                done();
                            }];
    }); });

    it(@"can be created", ^{ waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [BBURecordingHelper setUpCCLRequestReplayForNSURLSessionWithCDAClient:space.client];
        [[BBURecordingHelper sharedHelper] loadRecordingsForTestCase:[self class]];

        [space createAssetWithTitle:@{ @"en-US": @"My Asset" }
                        description:@{ @"en-US": @"some description" }
                       fileToUpload:nil
                            success:^(CDAResponse *response, CMAAsset *asset) {
                                expect(asset).toNot.beNil();

                                expect(asset.identifier).toNot.beNil();
                                expect(asset.sys[@"version"]).equal(@1);
                                expect(asset.fields[@"title"]).equal(@"My Asset");
                                expect(asset.title).equal(@"My Asset");

                                done();
                            } failure:^(CDAResponse *response, NSError *error) {
                                XCTFail(@"Error: %@", error);

                                done();
                            }];
    }); });

    it(@"can be created with user-defined identifier", ^{ waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [BBURecordingHelper setUpCCLRequestReplayForNSURLSessionWithCDAClient:space.client];
        [[BBURecordingHelper sharedHelper] loadRecordingsForTestCase:[self class]];
        [space createAssetWithIdentifier:@"foo"
                                  fields:@{ @"title": @{ @"en-US": @"My Asset" } }
                                 success:^(CDAResponse *response, CMAAsset *asset) {
                                     expect(asset).toNot.beNil();

                                     expect(asset.identifier).equal(@"foo");
                                     expect(asset.sys[@"version"]).equal(@1);
                                     expect(asset.fields[@"title"]).equal(@"My Asset");

                                     [asset deleteWithSuccess:^{
                                         done();
                                     } failure:^(CDAResponse *response, NSError *error) {
                                         XCTFail(@"Error: %@", error);

                                         done();
                                     }];
                                 } failure:^(CDAResponse *response, NSError *error) {
                                     XCTFail(@"Error: %@", error);

                                     done();
                                 }];
    }); });

    it(@"can be deleted", ^{ waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [BBURecordingHelper setUpCCLRequestReplayForNSURLSessionWithCDAClient:space.client];
        [[BBURecordingHelper sharedHelper] loadRecordingsForTestCase:[self class]];
        [space createAssetWithTitle:nil
                        description:nil
                       fileToUpload:nil
                            success:^(CDAResponse *response, CMAAsset *asset) {
                                expect(asset).toNot.beNil();

                                [asset deleteWithSuccess:^{
                                    if (![BBURecordingHelper sharedHelper].isReplaying) {
                                        [NSThread sleepForTimeInterval:5.0];
                                    }

                                    [space fetchAssetWithIdentifier:asset.identifier
                                                            success:^(CDAResponse *response,
                                                                      CMAAsset *asset) {
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

    it(@"can process its file", ^{ waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");

        [BBURecordingHelper setUpCCLRequestReplayForNSURLSessionWithCDAClient:space.client];
        [[BBURecordingHelper sharedHelper] loadRecordingsForTestCase:[self class]];

        [space createAssetWithTitle:@{ @"en-US": @"Bacon Pancakes" }
                        description:nil
                       fileToUpload:@{ @"en-US": @"http://i.imgur.com/vaa4by0.png" }
                            success:^(CDAResponse *response, CMAAsset *asset) {
                                [asset processWithSuccess:^{
                                    done();
                                } failure:^(CDAResponse *response, NSError *error) {
                                    XCTFail(@"Error: %@", error);

                                    done();
                                }];
                            } failure:^(CDAResponse *response, NSError *error) {
                                XCTFail(@"Error: %@", error);

                                done();
                            }];
    }); });
//
//    it(@"can be published successfully", ^{ waitUntil(^(DoneCallback done) {
//        NSAssert(space, @"Test space could not be found.");
//
//        [BBURecordingHelper setUpCCLRequestReplayForNSURLSessionWithCDAClient:space.client];
//        [[BBURecordingHelper sharedHelper] loadRecordingsForTestCase:[self class]];
//
//        [space createAssetWithTitle:@{ @"en-US": @"Bacon Pancakes" }
//                        description:nil
//                       fileToUpload:@{ @"en-US": @"http://i.imgur.com/vaa4by0.png" }
//                            success:^(CDAResponse *response, CMAAsset *asset) {
//                                [asset processWithSuccess:^{
//                                    if (![BBURecordingHelper sharedHelper].isReplaying) {
//                                        [NSThread sleepForTimeInterval:5.0];
//                                    }
//
//                                    [asset publishWithSuccess:^{
//                                        expect(asset.isPublished).to.beTruthy();
//
//                                        done();
//                                    } failure:^(CDAResponse *response, NSError *error) {
//                                        XCTFail(@"Error: %@", error);
//
//                                        done();
//                                    }];
//                                } failure:^(CDAResponse *response, NSError *error) {
//                                    XCTFail(@"Error: %@", error);
//
//                                    done();
//                                }];
//                            } failure:^(CDAResponse *response, NSError *error) {
//                                XCTFail(@"Error: %@", error);
//
//                                done();
//                            }];
//    }); });
//
//    it(@"cannot be published without associated file", ^{ waitUntil(^(DoneCallback done) {
//        NSAssert(space, @"Test space could not be found.");
//        [BBURecordingHelper setUpCCLRequestReplayForNSURLSessionWithCDAClient:space.client];
//        [[BBURecordingHelper sharedHelper] loadRecordingsForTestCase:[self class]];
//        [space createAssetWithTitle:nil
//                        description:nil
//                       fileToUpload:nil
//                            success:^(CDAResponse *response, CMAAsset *asset) {
//                                expect(asset).toNot.beNil();
//
//                                [asset publishWithSuccess:^{
//                                    XCTFail(@"Should not succeed.");
//
//                                    done();
//                                } failure:^(CDAResponse *response, NSError *error) {
//                                    done();
//                                }];
//                            } failure:^(CDAResponse *response, NSError *error) {
//                                XCTFail(@"Error: %@", error);
//
//                                done();
//                            }];
//    }); });
//
//    it(@"cannot be unpublished from draft state", ^{ waitUntil(^(DoneCallback done) {
//        NSAssert(space, @"Test space could not be found.");
//        [space createAssetWithTitle:nil
//                        description:nil
//                       fileToUpload:nil
//                            success:^(CDAResponse *response, CMAAsset *asset) {
//                                expect(asset).toNot.beNil();
//
//                                [asset unpublishWithSuccess:^{
//                                    XCTFail(@"Should not succeed.");
//
//                                    done();
//                                } failure:^(CDAResponse *response, NSError *error) {
//                                    done();
//                                }];
//                            } failure:^(CDAResponse *response, NSError *error) {
//                                XCTFail(@"Error: %@", error);
//
//                                done();
//                            }];
//    }); });
//
//    it(@"can be unarchived", ^{ waitUntil(^(DoneCallback done) {
//        NSAssert(space, @"Test space could not be found.");
//        [space createAssetWithTitle:nil
//                        description:nil
//                       fileToUpload:nil
//                            success:^(CDAResponse *response, CMAAsset *asset) {
//                                expect(asset).toNot.beNil();
//
//                                [asset archiveWithSuccess:^{
//                                    expect(asset.sys[@"archivedVersion"]).equal(@1);
//
//                                    [asset unarchiveWithSuccess:^{
//                                        expect(asset.sys[@"archivedVersion"]).to.beNil();
//
//                                        done();
//                                    } failure:^(CDAResponse *response, NSError *error) {
//                                        XCTFail(@"Error: %@", error);
//
//                                        done();
//                                    }];
//                                } failure:^(CDAResponse *response, NSError *error) {
//                                    XCTFail(@"Error: %@", error);
//
//                                    done();
//                                }];
//                            } failure:^(CDAResponse *response, NSError *error) {
//                                XCTFail(@"Error: %@", error);
//                                
//                                done();
//                            }];
//    }); });
//
//    it(@"can be updated", ^{ waitUntil(^(DoneCallback done) {
//        NSAssert(space, @"Test space could not be found.");
//        [space createAssetWithTitle:@{ @"en-US": @"foo" }
//                        description:nil
//                       fileToUpload:nil
//                            success:^(CDAResponse *response, CMAAsset *asset) {
//                                expect(asset).toNot.beNil();
//
//                                asset.title = @"bar";
//                                asset.description = @"description";
//
//                                [asset updateWithSuccess:^{
//                                    if (![BBURecordingHelper sharedHelper].isReplaying) {
//                                        [NSThread sleepForTimeInterval:8.0];
//                                    }
//
//                                    [space fetchAssetWithIdentifier:asset.identifier success:^(CDAResponse *response, CMAAsset* newAsset) {
//                                        expect(asset.locale).to.equal(@"en-US");
//                                        expect(asset.fields[@"title"]).equal(@"bar");
//                                        expect(asset.sys[@"version"]).equal(@2);
//                                        expect(asset.description).equal(@"description");
//
//                                        expect(newAsset).toNot.beNil();
//                                        expect(newAsset.fields[@"title"]).equal(@"bar");
//                                        expect(newAsset.sys[@"version"]).equal(@2);
//
//                                        done();
//                                    } failure:^(CDAResponse *response, NSError *error) {
//                                        XCTFail(@"Error: %@", error);
//
//                                        done();
//                                    }];
//                                } failure:^(CDAResponse *response, NSError *error) {
//                                    XCTFail(@"Error: %@", error);
//
//                                    done();
//                                }];
//                            } failure:^(CDAResponse *response, NSError *error) {
//                                XCTFail(@"Error: %@", error);
//                                
//                                done();
//                            }];
//    }); });
//
//    it(@"can update its file", ^{ waitUntil(^(DoneCallback done) {
//        NSAssert(space, @"Test space could not be found.");
//        [space createAssetWithTitle:nil
//                        description:nil
//                       fileToUpload:@{ @"en-US": @"http://i.imgur.com/vaa4by0.png" }
//                            success:^(CDAResponse *response, CMAAsset *asset) {
//                                expect(asset).toNot.beNil();
//                                expect(asset.isImage).to.beTruthy();
//
//                                [asset updateWithLocalizedUploads:@{ @"en-US": @"http://www.dogecoinforhumans.com/dogecoin-for-humans.pdf" }
//                                                          success:^{
//                                                              expect(asset).toNot.beNil();
//                                                              expect(asset.isImage).to.beFalsy();
//
//                                                              done();
//                                                          } failure:^(CDAResponse *response,
//                                                                      NSError *error) {
//                                                              XCTFail(@"Error: %@", error);
//
//                                                              done();
//                                                          }];
//                            } failure:^(CDAResponse *response, NSError *error) {
//                                XCTFail(@"Error: %@", error);
//
//                                done();
//                            }];
//    }); });
});

SpecEnd
