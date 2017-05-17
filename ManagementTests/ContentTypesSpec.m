//
//  ContentTypesSpec.m
//  ManagementSDK
//
//  Created by Boris Bügling on 29/07/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <Keys/ContentfulSDKKeys.h>
#import <ContentfulManagementAPI/ContentfulManagementAPI.h>
#import <VCRURLConnection/VCR.h>
#import "TestHelpers.h"

#define ArrayTestWithItemType(__itemType) NSAssert(space, @"Test space could not be found."); \
\
CMAField* arrayField = [CMAField fieldWithName:@"Array" type:CDAFieldTypeArray]; \
arrayField.itemType = __itemType; \
\
[space createContentTypeWithName:@"foobar" \
                          fields:@[ arrayField ] \
                         success:^(CDAResponse *response, CMAContentType *contentType) { \
                             expect(contentType).toNot.beNil(); \
                             expect(contentType.fields.count).to.equal(1); \
\
                             [contentType publishWithSuccess:^{ \
                                 expect(contentType).toNot.beNil(); \
                                 expect(contentType.fields.count).to.equal(1); \
\
                                 [contentType unpublishWithSuccess:^{ \
                                     expect(contentType).toNot.beNil(); \
                                     expect(contentType.fields.count).to.equal(1); \
\
                                     [contentType deleteWithSuccess:^{ \
                                         done(); \
                                     } failure:^(CDAResponse *response, NSError *error) { \
                                         XCTFail(@"Error: %@", error); \
\
                                         done(); \
                                     }]; \
                                 } failure:^(CDAResponse *response, NSError *error) { \
                                     XCTFail(@"Error: %@", error); \
\
                                     done(); \
                                 }]; \
                             } failure:^(CDAResponse *response, NSError *error) { \
                                 XCTFail(@"Error: %@", error); \
\
                                 done(); \
                             }]; \
                         } failure:^(CDAResponse *response, NSError *error) { \
                             XCTFail(@"Error: %@", error); \
\
                             done(); \
                         }];

SpecBegin(ContentType)

describe(@"Content Type", ^{
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


    VCRTest_it(@"can_be_activated")

    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");

        [space createContentTypeWithName:@"foobar"
                                  fields:@[ [CMAField fieldWithName:@"foo" type:CDAFieldTypeDate] ]
                                 success:^(CDAResponse *response, CMAContentType *contentType) {
                                     expect(contentType).toNot.beNil();
                                     expect(contentType.isPublished).to.equal(NO);

                                     [contentType publishWithSuccess:^{
                                         expect(contentType.sys[@"publishedCounter"]).equal(@1);
                                         expect(contentType.isPublished).to.equal(YES);

                                         [contentType unpublishWithSuccess:^{
                                             expect(contentType.isPublished).to.equal(NO);

                                             [contentType deleteWithSuccess:^{
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
                                 } failure:^(CDAResponse *response, NSError *error) {
                                     XCTFail(@"Error: %@", error);

                                     done();
                                 }];
    });
    VCRTestEnd

    VCRTest_it(@"can_be_deactivated")

    waitUntil(^(DoneCallback done) {

        NSAssert(space, @"Test space could not be found.");

        [space createContentTypeWithName:@"foobar"
                                  fields:@[ [CMAField fieldWithName:@"foo" type:CDAFieldTypeDate] ]
                                 success:^(CDAResponse *response, CMAContentType *contentType) {
                                     expect(contentType).toNot.beNil();

                                     [contentType publishWithSuccess:^{
                                         expect(contentType.sys[@"publishedVersion"]).equal(@1);

                                         [contentType unpublishWithSuccess:^{
                                             expect(contentType.sys[@"publishedVersion"]).to.beNil();

                                             [contentType deleteWithSuccess:^{
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
                                 } failure:^(CDAResponse *response, NSError *error) {
                                     XCTFail(@"Error: %@", error);
                                     
                                     done();
                                 }];
    });
    VCRTestEnd


    VCRTest_it(@"can_be_created")

    waitUntil(^(DoneCallback done) {

        NSAssert(space, @"Test space could not be found.");
        [space createContentTypeWithName:@"foobar"
                                  fields:@[ [CMAField fieldWithName:@"Date" type:CDAFieldTypeDate],
                                            [CMAField fieldWithName:@"Bool" type:CDAFieldTypeBoolean],
                                            [CMAField fieldWithName:@"Loc" type:CDAFieldTypeLocation],
                                            [CMAField fieldWithName:@"Int" type:CDAFieldTypeInteger],
                                            [CMAField fieldWithName:@"Num" type:CDAFieldTypeNumber],
                                            [CMAField fieldWithName:@"Obj" type:CDAFieldTypeObject],
                                            [CMAField fieldWithName:@"Text" type:CDAFieldTypeText],
                                            [CMAField fieldWithName:@"Sym" type:CDAFieldTypeSymbol] ]
                                 success:^(CDAResponse *response, CMAContentType *contentType) {
                                     expect(contentType).toNot.beNil();
                                     expect(contentType.fields.count).equal(8);

                                     [contentType deleteWithSuccess:^{
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


    VCRTest_it(@"can_be_created_with_symbols_array_field-type")

    waitUntil(^(DoneCallback done) {

        ArrayTestWithItemType(CDAFieldTypeSymbol);
    });
    VCRTestEnd


    VCRTest_it(@"can_be_created_with_linked_entries_array_field-type")

    waitUntil(^(DoneCallback done) {
        ArrayTestWithItemType(CDAFieldTypeEntry);
    });
    VCRTestEnd


    VCRTest_it(@"can_be_created_with_linked_assets_array_field-type")

    waitUntil(^(DoneCallback done) {

        ArrayTestWithItemType(CDAFieldTypeAsset);
    });
    VCRTestEnd

    VCRTest_it(@"can_be_created_with_linked_entry_field-type")

    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");

        [space createContentTypeWithName:@"foobar"
                                  fields:@[ [CMAField fieldWithName:@"Link" type:CDAFieldTypeEntry] ]
                                 success:^(CDAResponse *response, CMAContentType *contentType) {
                                     expect(contentType).toNot.beNil();
                                     expect(contentType.fields.count).equal(1);

                                     [contentType publishWithSuccess:^{
                                         expect(contentType).toNot.beNil();
                                         expect(contentType.fields.count).equal(1);
                                         expect(contentType.sys[@"publishedVersion"]).equal(@1);

                                         [contentType unpublishWithSuccess:^{
                                             expect(contentType).toNot.beNil();
                                             expect(contentType.fields.count).equal(1);
                                             expect(contentType.sys[@"publishedVersion"]).to.beNil();

                                             [contentType deleteWithSuccess:^{
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
                                 } failure:^(CDAResponse *response, NSError *error) {
                                     XCTFail(@"Error: %@", error);

                                     done();
                                 }];
    });
    VCRTestEnd

    VCRTest_it(@"can_be_deleted")


    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space createContentTypeWithName:@"foobar"
                                  fields:nil
                                 success:^(CDAResponse *response, CMAContentType *contentType) {
                                     expect(contentType).toNot.beNil();
                                     expect(contentType.fields.count).equal(0);

                                     [contentType deleteWithSuccess:^{

                                         if (![VCR isReplaying]) {
                                             [NSThread sleepForTimeInterval:8.0];
                                         }

                                         [space fetchContentTypeWithIdentifier:contentType.identifier
                                                                       success:^(CDAResponse *response,
                                                                                 CMAContentType *ct) {
                                                                           dispatch_sync(dispatch_get_main_queue(), ^{
                                                                               XCTFail(@"Should not succeed.");
                                                                           });

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

    VCRTest_it(@"does_not_change_during_update")

    waitUntil(^(DoneCallback done) {

        NSAssert(space, @"Test space could not be found.");
        [space createContentTypeWithName:@"foobar"
                                  fields:@[ [CMAField fieldWithName:@"Date" type:CDAFieldTypeDate],
                                            [CMAField fieldWithName:@"Bool" type:CDAFieldTypeBoolean],
                                            [CMAField fieldWithName:@"Loc" type:CDAFieldTypeLocation],
                                            [CMAField fieldWithName:@"Int" type:CDAFieldTypeInteger],
                                            [CMAField fieldWithName:@"Num" type:CDAFieldTypeNumber],
                                            [CMAField fieldWithName:@"Obj" type:CDAFieldTypeObject],
                                            [CMAField fieldWithName:@"Text" type:CDAFieldTypeText],
                                            [CMAField fieldWithName:@"Sym" type:CDAFieldTypeSymbol] ]
                                 success:^(CDAResponse *response, CMAContentType *contentType) {
                                     expect(contentType).toNot.beNil();
                                     expect(contentType.fields.count).equal(8);

                                     [contentType updateWithSuccess:^{
                                         expect(contentType).toNot.beNil();
                                         expect(contentType.fields.count).equal(8);

                                         [contentType deleteWithSuccess:^{
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

    VCRTest_it(@"can_update_with_added_field")

    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space createContentTypeWithName:@"foobar"
                                  fields:@[ [CMAField fieldWithName:@"field" type:CDAFieldTypeText] ]
                                 success:^(CDAResponse *response, CMAContentType *contentType) {
                                     expect(contentType).toNot.beNil();
                                     expect(contentType.fields.count).equal(1);

                                     [contentType addFieldWithName:@"anotherField"
                                                              type:CDAFieldTypeNumber];
                                     [contentType updateWithSuccess:^{
                                         expect(contentType).toNot.beNil();
                                         expect(contentType.fields.count).equal(2);

                                         [contentType deleteWithSuccess:^{
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

    VCRTest_it(@"can_update_with_added_field_created_manually")

    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space createContentTypeWithName:@"foobar"
                                  fields:@[ [CMAField fieldWithName:@"field" type:CDAFieldTypeText] ]
                                 success:^(CDAResponse *response, CMAContentType *contentType) {
                                     expect(contentType).toNot.beNil();
                                     expect(contentType.fields.count).equal(1);

                                     CMAField* field = [CMAField fieldWithName:@"anotherField"
                                                                          type:CDAFieldTypeNumber];
                                     [contentType addField:field];

                                     [contentType updateWithSuccess:^{
                                         expect(contentType).toNot.beNil();
                                         expect(contentType.fields.count).equal(2);

                                         [contentType deleteWithSuccess:^{
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

    VCRTest_it(@"can_update_with_deleted_field")

    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space createContentTypeWithName:@"foobar"
                                  fields:@[ [CMAField fieldWithName:@"field1" type:CDAFieldTypeText],
                                            [CMAField fieldWithName:@"field2" type:CDAFieldTypeText],
                                            [CMAField fieldWithName:@"field3" type:CDAFieldTypeText] ]
                                 success:^(CDAResponse *response, CMAContentType *contentType) {
                                     expect(contentType).toNot.beNil();
                                     expect(contentType.fields.count).equal(3);

                                     NSString* identifier = [contentType.fields.firstObject identifier];
                                     [contentType deleteFieldWithIdentifier:identifier];
                                     [contentType deleteField:contentType.fields.firstObject];

                                     [contentType updateWithSuccess:^{
                                         expect(contentType).toNot.beNil();
                                         expect(contentType.fields.count).equal(1);

                                         [contentType deleteWithSuccess:^{
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

    VCRTest_it(@"can_update_name_of_an_existing")

    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space createContentTypeWithName:@"foobar"
                                  fields:@[ [CMAField fieldWithName:@"field1" type:CDAFieldTypeText]]
                                 success:^(CDAResponse *response, CMAContentType *contentType) {
                                     expect(contentType).toNot.beNil();
                                     expect(contentType.fields.count).equal(1);
                                     expect([contentType.fields.firstObject name]).equal(@"field1");

                                     [contentType updateName:@"foobar" ofFieldWithIdentifier:@"field1"];
                                     [contentType updateWithSuccess:^{
                                         expect(contentType).toNot.beNil();
                                         expect(contentType.fields.count).equal(1);
                                         expect([contentType.fields.firstObject identifier]).equal(@"field1");
                                         expect([contentType.fields.firstObject name]).equal(@"foobar");

                                         [contentType deleteWithSuccess:^{
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

    VCRTest_it(@"can_update_type_of_an_existing_field")

    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space createContentTypeWithName:@"foobar"
                                  fields:@[ [CMAField fieldWithName:@"field1" type:CDAFieldTypeText]]
                                 success:^(CDAResponse *response, CMAContentType *contentType) {
                                     expect(contentType).toNot.beNil();
                                     expect(contentType.fields.count).equal(1);

                                     __block CMAField* field = contentType.fields.firstObject;
                                     expect(field.type).equal(CDAFieldTypeText);

                                     [contentType updateType:CDAFieldTypeDate ofFieldWithIdentifier:@"field1"];
                                     [contentType updateWithSuccess:^{
                                         expect(contentType).toNot.beNil();
                                         expect(contentType.fields.count).equal(1);

                                         field = contentType.fields.firstObject;
                                         expect(field.identifier).equal(@"field1");
                                         expect(field.type).equal(CDAFieldTypeDate);

                                         [contentType deleteWithSuccess:^{
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


    VCRTest_it(@"can_update_with_changed_name")

    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space createContentTypeWithName:@"name"
                                  fields:nil
                                 success:^(CDAResponse *response, CMAContentType *contentType) {
                                     expect(contentType).toNot.beNil();
                                     expect(contentType.name).to.equal(@"name");

                                     contentType.name = @"changed name";
                                     [contentType updateWithSuccess:^{
                                         expect(contentType).toNot.beNil();
                                         expect(contentType.name).to.equal(@"changed name");

                                         [contentType deleteWithSuccess:^{
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

    VCRTest_it(@"can_update_with_changed_description")

    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space createContentTypeWithName:@"name"
                                  fields:nil
                                 success:^(CDAResponse *response, CMAContentType *contentType) {
                                     expect(contentType).toNot.beNil();
                                     expect(contentType.userDescription).to.beNil();

                                     contentType.userDescription = @"changed description";
                                     [contentType updateWithSuccess:^{
                                         expect(contentType).toNot.beNil();
                                         expect(contentType.userDescription).to.equal(@"changed description");

                                         [contentType deleteWithSuccess:^{
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

    VCRTest_it(@"cannot_add_two_fields_with_same_name")

    waitUntil(^(DoneCallback done) {

        NSAssert(space, @"Test space could not be found.");
        [space createContentTypeWithName:@"foobar"
                                  fields:@[ [CMAField fieldWithName:@"field" type:CDAFieldTypeText] ]
                                 success:^(CDAResponse *response, CMAContentType *contentType) {
                                     expect(contentType).toNot.beNil();
                                     expect(contentType.fields.count).equal(1);

                                     [contentType addFieldWithName:@"field" type:CDAFieldTypeNumber];
                                     [contentType updateWithSuccess:^{
                                         expect(contentType).toNot.beNil();
                                         expect(contentType.fields.count).equal(1);

                                         [contentType deleteWithSuccess:^{
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

    it(@"does_not_crash_when_creating_a_field_with_an_empty_name", ^{
        CMAField* field = [CMAField fieldWithName:@"" type:CDAFieldTypeBoolean];
        expect(field.identifier).equal(@"");
    });

    it(@"correctly generates identifiers for fields with spaces in the name", ^{
        CMAField* field = [CMAField fieldWithName:@"my field" type:CDAFieldTypeBoolean];
        expect(field.identifier).equal(@"myField");
    });
});

SpecEnd
