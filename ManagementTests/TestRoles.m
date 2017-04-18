//
//  TestRoles.m
//  ManagementSDK
//
//  Created by Boris Bügling on 22/12/15.
//  Copyright © 2015 Boris Bügling. All rights reserved.
//

#import <Keys/ManagementSDKKeys.h>
#import <ContentfulManagementAPI/ContentfulManagementAPI.h>

#import "BBURecordingHelper.h"

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

/*
 The spec name is a result of the test recordings being essential to a working testsuite right now
 and the recordings are order dependant.
 */
SpecBegin(XX)

describe(@"Roles", ^{
    __block CMAClient* client;
    __block CMASpace* space;

    RECORD_TESTCASE

    beforeEach(^{ waitUntil(^(DoneCallback done) {
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
    }); });

#if 0 // TODO: Test disabled for now because the account used for testing doesn't work with R&P
    it(@"can create a new role", ^{ waitUntil(^(DoneCallback done) {
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
                              XCTAssertEqualObjects(role.description, description);
                              XCTAssertEqualObjects(role.permissions, permissions);
                              XCTAssertEqualObjects(role.policies, policies);

                              done();
                          }
                          failure:^(CDAResponse *response, NSError *error) {
                              XCTFail("Error: %@", error);

                              done();
                          }];
    }); });
#endif

    it(@"can fetch roles", ^{ waitUntil(^(DoneCallback done) {
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
    }); });

    it(@"can fetch a single role", ^{ waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space fetchRoleWithIdentifier:@"2jEj26wGn3Au6E7yG2rBhc"
                               success:^(CDAResponse *response, CMARole *role) {
                                   validateEditorRole(self, role);

                                   done();
                               } failure:^(CDAResponse *response, NSError *error) {
                                   XCTFail("Error: %@", error);

                                   done();
                               }];
    }); });

    it(@"can update a single role", ^{ waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space fetchRoleWithIdentifier:@"7zStucnmwK4vSHUKRRcV73"
                               success:^(CDAResponse *response, CMARole *role) {
                                   XCTAssertNotNil(role);
                                   XCTAssertEqualObjects(role.roleDescription, @"Allows only editing of content they created themselves");

                                   role.roleDescription = @"YOLO";

                                   [role updateWithSuccess:^{
                                       [space fetchRoleWithIdentifier:@"7zStucnmwK4vSHUKRRcV73"
                                                              success:^(CDAResponse *r, CMARole *role) {
                                                                  XCTAssertEqualObjects(role.roleDescription, @"YOLO");

                                                                  done();
                                                              } failure:^(CDAResponse *r, NSError *e) {
                                                                  XCTFail("Error: %@", e);

                                                                  done();
                                                              }];
                                   } failure:^(CDAResponse *response, NSError *error) {
                                       XCTFail("Error: %@", error);

                                       done();
                                   }];
                               } failure:^(CDAResponse *response, NSError *error) {
                                   XCTFail("Error: %@", error);

                                   done();
                               }];
    }); });

    it(@"can delete a single role", ^{ waitUntil(^(DoneCallback done) {
        NSAssert(space, @"Test space could not be found.");
        [space fetchRoleWithIdentifier:@"7A5qhAwxThimzbpCe8FLhn"
                               success:^(CDAResponse *response, CMARole *role) {
                                   [role deleteWithSuccess:^{
                                       [space fetchRoleWithIdentifier:@"7A5qhAwxThimzbpCe8FLhn"
                                                              success:^(CDAResponse* r, CMARole* role) {
                                                                  XCTFail(@"Role should not exists.");

                                                                  done();
                                                              } failure:^(CDAResponse* r, NSError* e) {
                                                                  done();
                                                              }];
                                   } failure:^(CDAResponse *response, NSError *error) {
                                       XCTFail("Error: %@", error);

                                       done();
                                   }];
                               } failure:^(CDAResponse *response, NSError *error) {
                                   XCTFail("Error: %@", error);

                                   done();
                               }];
    }); });
});

SpecEnd

