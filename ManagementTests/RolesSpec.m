//
//  TestRoles.m
//  ManagementSDK
//
//  Created by Boris Bügling on 22/12/15.
//  Copyright © 2015 Boris Bügling. All rights reserved.
//

#import <Keys/ContentfulSDKKeys.h>
#import <ContentfulManagementAPI/ContentfulManagementAPI.h>
#import <VCRURLConnection/VCR.h>
#import "TestHelpers.h"
#import "CDAUtilities.h"

void validateEditorRole(id self, CMARole* editorRole) {
    NSDictionary* expectedPermissions = @{
                                          @"ContentDelivery": @[],
                                          @"ContentModel": @[ @"read" ],
                                          @"Settings": @[]
                                          };

    NSArray* expectedPolicies = @[
                                  @{
                                      @"actions": @"all",
                                      @"constraint": @{
                                              @"and": @[ @{ @"equals": @[ @{ @"doc": @"sys.type" }, @"Asset" ] } ]
                                              },
                                      @"effect": @"allow"
                                      },
                                  @{
                                      @"actions": @"all",
                                      @"constraint": @{
                                              @"and": @[ @{ @"equals": @[ @{ @"doc": @"sys.type" }, @"Entry" ] } ]
                                              },
                                      @"effect": @"allow"
                                      } ];

    XCTAssertNotNil(editorRole);
    XCTAssertEqualObjects(editorRole.roleDescription, @"Allows editing of all Entries");
    XCTAssertEqualObjects(editorRole.permissions, expectedPermissions);
    XCTAssertEqualObjects(editorRole.policies, expectedPolicies);
}

SpecBegin(Roles)

describe(@"Roles", ^{
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


    VCRTest_it(@"can_create_and_delete_role")
    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");

        NSString* name = @"YOLO";
        NSString* description = @"The best role ever";
        NSDictionary* permissions = @{ @"ContentDelivery": @[],
                                       @"ContentModel": @[ @"read" ],
                                       @"Settings": @[] };
        NSArray* policies = @[ @{ @"actions": @"all", @"constraint": @{ @"equals": @[ @{ @"doc": @"sys.type" }, @"Entry" ] }, @"effect": @"allow" } ];

        [space createRoleWithName:name
                      description:description
                      permissions:permissions
                         policies:policies
                          success:^(CDAResponse *response, CMARole *role) {
                              XCTAssertNotNil(role);
                              XCTAssertEqualObjects(role.name, name);
                              XCTAssertEqualObjects(role.roleDescription, description);
                              XCTAssertEqualObjects(role.permissions, permissions);
                              XCTAssertEqualObjects(role.policies, policies);

                              [role deleteWithSuccess:^{
                                  done();
                              } failure:^(CDAResponse * _Nullable response, NSError * _Nonnull error) {
                                  XCTFail("Error: %@", error);

                                  done();
                              }];
                          }
                          failure:^(CDAResponse *response, NSError *error) {
                              XCTFail("Error: %@", error);

                              done();
                          }];
    });
    VCRTestEnd


    VCRTest_it(@"can_fetch_roles")

    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space fetchRolesMatching:@{}
                      withSuccess:^(CDAResponse *response, CDAArray *array) {
                          XCTAssertEqual(array.items.count, 7);

                          CMARole* editorRole = nil;
                          for (CMARole* role in array.items) {
                              if ([role.name isEqualToString:@"Editor"]) {
                                  editorRole = role;
                                  break;
                              }
                          }

                          validateEditorRole(self, editorRole);
                          done();
                      } failure:^(CDAResponse *response, NSError *error) {
                          XCTFail("Error: %@", error);

                          done();
                      }];
    });
    VCRTestEnd

    VCRTest_it(@"can_fetch_single_role")
    waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space fetchRoleWithIdentifier:@"2jEj26wGn3Au6E7yG2rBhc"
                               success:^(CDAResponse *response, CMARole *role) {
                                   validateEditorRole(self, role);

                                   done();
                               } failure:^(CDAResponse *response, NSError *error) {
                                   XCTFail("Error: %@", error);

                                   done();
                               }];
    });
    VCRTestEnd


    // This test hits the same fetch endpoint twice, so we must use different recordings.
    it(@"can_update_single_role", ^{

        NSString *roleId = @"7zStucnmwK4vSHUKRRcV73";
        NSString *newRoleDescription = @"YOLO";
        NSString *originalRoleDescription = @"Allows only editing of content they created themselves";

        NSString *updateRoleTestName = @"can_successfully_update_role";


        [TestHelpers startRecordingOrLoadCassetteForTestNamed:updateRoleTestName
                                                     forClass:self.class];
        waitUntil(^(DoneCallback done) {
            NSAssert(space, @"Test space could not be found.");


            [space fetchRoleWithIdentifier:roleId
                       success:^(CDAResponse *response, CMARole *role) {
                           XCTAssertNotNil(role);
                           XCTAssertEqualObjects(role.roleDescription, originalRoleDescription);

                           role.roleDescription = newRoleDescription;

                           [role updateWithSuccess:^{
                               if (![VCR isReplaying]) {
                                   [NSThread sleepForTimeInterval:3.0];
                               }
                               done();
                           } failure:^(CDAResponse *response, NSError *error) {
                               XCTFail("Error: %@", error);

                               done();
                           }];
                       } failure:^(CDAResponse *response, NSError *error) {
                           XCTFail("Error: %@", error);

                           done();
                       }];
        });
        [TestHelpers endRecordingAndSaveWithName:updateRoleTestName
                                        forClass:self.class];

        NSString *updatedRoleCorrectlyTestName = @"updated_role_has_correct_description";

        [TestHelpers startRecordingOrLoadCassetteForTestNamed:updatedRoleCorrectlyTestName
                                                     forClass:self.class];
        // Second fetch with different recording
        waitUntil(^(DoneCallback done) {
            [space fetchRoleWithIdentifier:roleId
                                   success:^(CDAResponse *r, CMARole *role) {
                                       XCTAssertNotNil(role);
                                       XCTAssertEqualObjects(role.roleDescription, newRoleDescription);

                                       role.roleDescription = originalRoleDescription;

                                       [role updateWithSuccess:^{
                                           if (![VCR isReplaying]) {
                                               [NSThread sleepForTimeInterval:3.0];
                                           }
                                           done();
                                       } failure:^(CDAResponse *response, NSError *error) {
                                           XCTFail("Error: %@", error);
                                           
                                           done();
                                       }];
                                   } failure:^(CDAResponse *r, NSError *e) {
                                       XCTFail("Error: %@", e);

                                       done();
                                   }];
        });
        [TestHelpers endRecordingAndSaveWithName:updatedRoleCorrectlyTestName
                                        forClass:self.class];
    });
});

SpecEnd

