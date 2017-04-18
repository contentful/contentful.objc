//
//  TestEntries.m
//  ManagementSDK
//
//  Created by Boris Bügling on 23/07/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <Keys/ManagementSDKKeys.h>
#import <ContentfulManagementAPI/ContentfulManagementAPI.h>

#import "BBURecordingHelper.h"
#import "CMASpace+Private.h"

SpecBegin(Entry)

describe(@"Entry", ^{
    __block CMAClient* client;
    __block CMAContentType* contentType;
    __block CMASpace* space;

    RECORD_TESTCASE

    beforeEach(^{ waitUntil(^(DoneCallback done) {
        NSString* token = [ManagementSDKKeys new].managementAPIAccessToken;

        client = [[CMAClient alloc] initWithAccessToken:token];

        [client fetchSpaceWithIdentifier:@"hvjkfbzcwrfn"
                                 success:^(CDAResponse *response, CMASpace *mySpace) {
                                     expect(mySpace).toNot.beNil();
                                     space = mySpace;

                                     [space fetchContentTypesWithSuccess:^(CDAResponse *response,
                                                                           CDAArray *array) {
                                         expect(array).toNot.beNil();

                                         for (CMAContentType* ct in array.items) {
                                             if ([ct.identifier isEqualToString:@"6FxqhReTPUuYAYW8gqOwS"]) {
                                                 contentType = ct;
                                                 break;
                                             }
                                         }

                                         expect(contentType.identifier).toNot.beNil();

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

    it(@"can be archived", ^{ waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space createEntryOfContentType:contentType
                             withFields:@{}
                                success:^(CDAResponse *response, CMAEntry *entry) {
                                    expect(entry.isArchived).to.beFalsy();

                                    [entry archiveWithSuccess:^{
                                        expect(entry.sys[@"archivedVersion"]).equal(@1);
                                        expect(entry.isArchived).to.beTruthy();

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
        [space createEntryOfContentType:contentType
                             withFields:@{ @"title": @{ @"en-US": @"Mr. President" } }
                                success:^(CDAResponse *response, CDAEntry *entry) {
                                    expect(entry).toNot.beNil();

                                    expect(entry.identifier).toNot.beNil();
                                    expect(entry.sys[@"version"]).equal(@1);
                                    expect(entry.fields[@"title"]).equal(@"Mr. President");

                                    done();
                                } failure:^(CDAResponse *response, NSError *error) {
                                    XCTFail(@"Error: %@", error);

                                    done();
                                }];
    }); });

    it(@"can be created with user-defined identifier", ^{ waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space createEntryOfContentType:contentType
                         withIdentifier:@"foo"
                                 fields:@{}
                                success:^(CDAResponse *response, CMAEntry *entry) {
                                    expect(entry).toNot.beNil();

                                    expect(entry.identifier).equal(@"foo");
                                    expect(entry.sys[@"version"]).equal(@1);

                                    [entry deleteWithSuccess:^{
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
        [space createEntryOfContentType:contentType
                             withFields:@{}
                                success:^(CDAResponse *response, CMAEntry *entry) {
                                    expect(entry).toNot.beNil();

                                    [entry deleteWithSuccess:^{
                                        if (![BBURecordingHelper sharedHelper].isReplaying) {
                                            [NSThread sleepForTimeInterval:5.0];
                                        }

                                        [space fetchEntryWithIdentifier:entry.identifier
                                                                success:^(CDAResponse *response,
                                                                          CDAEntry *entry) {
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

    it(@"can be published", ^{ waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space createEntryOfContentType:contentType
                             withFields:@{}
                                success:^(CDAResponse *response, CMAEntry *entry) {
                                    expect(entry.isPublished).to.equal(NO);

                                    [entry publishWithSuccess:^{
                                        expect(entry.sys[@"publishedCounter"]).equal(@1);
                                        expect(entry.isPublished).to.equal(YES);

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

    it(@"can be unarchived", ^{ waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space createEntryOfContentType:contentType
                             withFields:@{}
                                success:^(CDAResponse *response, CMAEntry *entry) {
                                    [entry archiveWithSuccess:^{
                                        expect(entry.sys[@"archivedVersion"]).equal(@1);

                                        [entry unarchiveWithSuccess:^{
                                            expect(entry.sys[@"archivedVersion"]).to.beNil();

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

    it(@"can be unpublished", ^{ waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space createEntryOfContentType:contentType
                             withFields:@{}
                                success:^(CDAResponse *response, CMAEntry *entry) {
                                    [entry publishWithSuccess:^{
                                        expect(entry.sys[@"publishedVersion"]).equal(@1);

                                        [entry unpublishWithSuccess:^{
                                            expect(entry.sys[@"publishedVersion"]).to.beNil();

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

    it(@"can set a location value", ^{ waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");

        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(40.0, 50.0);
        NSData* locationData = [NSData dataWithBytes:&location length:sizeof(location)];

        [space createEntryOfContentType:contentType
                             withFields:@{ @"location": @{ @"en-US": locationData } }
                                success:^(CDAResponse *response, CMAEntry *entry) {
                                    expect(entry).toNot.beNil();
                                    expect([entry CLLocationCoordinate2DFromFieldWithIdentifier:@"location"]).to.equal(location);

                                    done();
                                } failure:^(CDAResponse *response, NSError *error) {
                                    XCTFail(@"Error: %@", error);

                                    done();
                                }];
    }); });

    it(@"can be updated", ^{ waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");

        NSMutableDictionary* titles = [@{} mutableCopy];
        for (NSDictionary* locale in space.locales) {
            titles[locale[@"code"]] = @"foo";
        }

        [space createEntryOfContentType:contentType
                             withFields:@{ @"title": titles }
                                success:^(CDAResponse *response, CMAEntry *entry) {
                                    expect(entry).toNot.beNil();

                                    [entry setValue:@"bar" forFieldWithName:@"title"];
                                    [entry updateWithSuccess:^{
                                        if (![BBURecordingHelper sharedHelper].isReplaying) {
                                            [NSThread sleepForTimeInterval:8.0];
                                        }

                                        [space fetchEntryWithIdentifier:entry.identifier success:^  (CDAResponse *response, CDAEntry *newEntry) {
                                            expect(entry.fields[@"title"]).equal(@"bar");
                                            expect(entry.sys[@"version"]).equal(@2);

                                            expect(newEntry).toNot.beNil();
                                            expect(newEntry.fields[@"title"]).equal(@"bar");
                                            expect(newEntry.sys[@"version"]).equal(@2);

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
});

SpecEnd
