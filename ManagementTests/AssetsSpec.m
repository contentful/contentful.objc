//
//  AssetsSpec.m
//  ManagementSDK
//
//  Created by Boris Bügling on 28/07/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <ContentfulManagementAPI/ContentfulManagementAPI.h>
#import "CMASpace+Private.h"
#import <Keys/ContentfulSDKKeys.h>
#import <VCRURLConnection/VCR.h>

#import "TestHelpers.h"

SpecBegin(Asset)

describe(@"Asset", ^{
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
                                         expect(mySpace.name).equal(@"Obj-C CMA Test");
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

    VCRTest_it(@"can_be_archived")

    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");

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
    });
    VCRTestEnd


    VCRTest_it(@"can_be_created")

    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");

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
    });
    VCRTestEnd



    VCRTest_it(@"can_be_created_with_user-defined_identifier")

    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");

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
    });
    VCRTestEnd


    VCRTest_it(@"can_be_deleted")

    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");

        [space createAssetWithTitle:nil
                        description:nil
                       fileToUpload:nil
                            success:^(CDAResponse *response, CMAAsset *asset) {
                                expect(asset).toNot.beNil();

                                [asset deleteWithSuccess:^{

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
    });
    VCRTestEnd

    VCRTest_it(@"can_process_its_file")

    waitUntil(^(DoneCallback done) {

        NSAssert(space, @"Test space could not be found.");

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
    });
    VCRTestEnd


    VCRTest_it(@"can_be_published")

    waitUntil(^(DoneCallback done) {

        NSAssert(space, @"Test space could not be found.");

        [space createAssetWithTitle:@{ @"en-US": @"Bacon Pancakes" }
                        description:nil
                       fileToUpload:@{ @"en-US": @"http://i.imgur.com/vaa4by0.png" }
                            success:^(CDAResponse *response, CMAAsset *asset) {

                                [asset processWithSuccess:^{

                                    [asset publishWithSuccess:^{
                                        expect(asset.isPublished).to.beTruthy();

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

    VCRTest_it(@"cannot_be_published_without_associated_file")

    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");

        [space createAssetWithTitle:nil
                        description:nil
                       fileToUpload:nil
                            success:^(CDAResponse *response, CMAAsset *asset) {
                                expect(asset).toNot.beNil();

                                [asset publishWithSuccess:^{
                                    XCTFail(@"Should not succeed.");

                                    done();
                                } failure:^(CDAResponse *response, NSError *error) {
                                    done();
                                }];
                            } failure:^(CDAResponse *response, NSError *error) {
                                XCTFail(@"Error: %@", error);

                                done();
                            }];
    });
    VCRTestEnd

    
    VCRTest_it(@"cannot_be_unpublished_from_draft_state")

    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");

        [space createAssetWithTitle:nil
                        description:nil
                       fileToUpload:nil
                            success:^(CDAResponse *response, CMAAsset *asset) {
                                expect(asset).toNot.beNil();

                                [asset unpublishWithSuccess:^{
                                    XCTFail(@"Should not succeed.");

                                    done();
                                } failure:^(CDAResponse *response, NSError *error) {
                                    done();
                                }];
                            } failure:^(CDAResponse *response, NSError *error) {
                                XCTFail(@"Error: %@", error);

                                done();
                            }];
    });
    VCRTestEnd


    VCRTest_it(@"can_be_unarchived")
    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");

        [space createAssetWithTitle:nil
                        description:nil
                       fileToUpload:nil
                            success:^(CDAResponse *response, CMAAsset *asset) {
                                expect(asset).toNot.beNil();

                                [asset archiveWithSuccess:^{
                                    expect(asset.sys[@"archivedVersion"]).equal(@1);

                                    [asset unarchiveWithSuccess:^{
                                        expect(asset.sys[@"archivedVersion"]).to.beNil();

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


    VCRTest_it(@"can_be_updated");
    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");

        [space createAssetWithTitle:@{ @"en-US": @"foo" }
                        description:nil
                       fileToUpload:nil
                            success:^(CDAResponse *response, CMAAsset *asset) {
                                expect(asset).toNot.beNil();

                                asset.title = @"bar";
                                asset.description = @"description";

                                [asset updateWithSuccess:^{
                                    if (![VCR isReplaying]) {
                                        [NSThread sleepForTimeInterval:8.0];
                                    }
                                    [space fetchAssetWithIdentifier:asset.identifier success:^(CDAResponse *response, CMAAsset* newAsset) {
                                        expect(asset.locale).to.equal(@"en-US");
                                        expect(asset.fields[@"title"]).equal(@"bar");
                                        expect(asset.sys[@"version"]).equal(@2);
                                        expect(asset.description).equal(@"description");

                                        expect(newAsset).toNot.beNil();
                                        expect(newAsset.fields[@"title"]).equal(@"bar");
                                        expect(newAsset.sys[@"version"]).equal(@2);

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


    VCRTest_it(@"can_update_its_file")
    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");

        [space createAssetWithTitle:nil
                        description:nil
                       fileToUpload:@{ @"en-US": @"http://i.imgur.com/vaa4by0.png" }
                            success:^(CDAResponse *response, CMAAsset *asset) {
                                expect(asset).toNot.beNil();
                                expect(asset.isImage).to.beTruthy();

                                [asset updateWithLocalizedUploads:@{ @"en-US": @"http://www.dogecoinforhumans.com/dogecoin-for-humans.pdf" }
                                                          success:^{
                                                              expect(asset).toNot.beNil();
                                                              expect(asset.isImage).to.beFalsy();

                                                              done();
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
});

SpecEnd
