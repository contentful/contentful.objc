//
//  ClientConfiguration.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 01/10/14.
//
//

#import "ContentfulBaseTestCase.h"

@interface ClientConfiguration : ContentfulBaseTestCase

@end

#pragma mark -

@implementation ClientConfiguration

-(void)testClientCanBeInstantiatedWithoutSpaceKey {
    CDAClient* client1 = [[CDAClient alloc] initWithSpaceKey:nil accessToken:@"yolo"];
    CDAClient* client2 = [[CDAClient alloc] initWithSpaceKey:nil
                                                 accessToken:@"yolo"
                                               configuration:[CDAConfiguration defaultConfiguration]];

    XCTAssertNotNil(client1);
    XCTAssertNotNil(client2);
}

-(void)testDefaultUserAgent {
    StartBlock();

    CDARequest* request = [self.client fetchEntriesWithSuccess:^(CDAResponse *response,
                                                                 CDAArray *array) {
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        EndBlock();
    }];

    WaitUntilBlockCompletes();

    NSString* userAgent = request.request.allHTTPHeaderFields[@"User-Agent"];

    XCTAssertTrue([userAgent hasPrefix:@"contentful.objc"], @"");
}

-(void)testCustomUserAgent {
    CDAConfiguration* configuration = [CDAConfiguration defaultConfiguration];
    configuration.userAgent = @"CustomUserAgent/foo";
    self.client = [[CDAClient alloc] initWithSpaceKey:@"test"
                                          accessToken:@"test"
                                        configuration:configuration];

    StartBlock();

    CDARequest* request = [self.client fetchEntriesWithSuccess:^(CDAResponse *response,
                                                                 CDAArray *array) {
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        EndBlock();
    }];

    WaitUntilBlockCompletes();

    NSString* userAgent = request.request.allHTTPHeaderFields[@"User-Agent"];

    XCTAssertTrue([userAgent hasPrefix:@"CustomUserAgent/foo"], @"");
}

-(void)testFilterMissingEntities {
    CDAConfiguration* configuration = [CDAConfiguration defaultConfiguration];
    configuration.filterNonExistingResources = YES;

    self.client = [[CDAClient alloc] initWithSpaceKey:@"vfvjfjyjrbbp"
                                          accessToken:@"422588c021896d2ae01eaf2d68faa720aaf6da4b361e7c99e9afac6feacb498b"
                                        configuration:configuration];

    StartBlock();

    [self.client fetchEntriesWithSuccess:^(CDAResponse* response, CDAArray* array) {
        XCTAssertEqual(array.items.count, 1);

        CDAEntry* me = array.items.firstObject;
        XCTAssertNil(me.fields[@"link"]);

        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);

        EndBlock();
    }];

    WaitUntilBlockCompletes();
}

-(void)testNotFilterMissingEntitiesIfNotConfigured {
    self.client = [[CDAClient alloc] initWithSpaceKey:@"vfvjfjyjrbbp"
                                          accessToken:@"422588c021896d2ae01eaf2d68faa720aaf6da4b361e7c99e9afac6feacb498b"];

    StartBlock();

    [self.client fetchEntriesWithSuccess:^(CDAResponse* response, CDAArray* array) {
        XCTAssertEqual(array.items.count, 1);

        CDAEntry* me = array.items.firstObject;
        XCTAssertNotNil(me.fields[@"link"]);

        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);

        EndBlock();
    }];

    WaitUntilBlockCompletes();
}

@end
