//
//  LocaleTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 19/08/15.
//
//

#import "ContentfulBaseTestCase.h"

@interface LocaleTests : ContentfulBaseTestCase

@end

#pragma mark -

@implementation LocaleTests

-(void)testFallbackLocalesForAssets {
    StartBlock();

    self.client = [[CDAClient alloc] initWithSpaceKey:@"dmm6iymtengv"
                                          accessToken:@"b18e713cf2c3c8916cad0cca8e801a3c230e9e6781098dc50fb0810ebc36a4a1"];

    [self.client fetchAssetsMatching:@{ @"locale": @"*" } success:^(CDAResponse* r, CDAArray* array) {
        CDAAsset* asset = array.items.firstObject;
        XCTAssertNotNil(asset.URL);

        asset.locale = @"es";
        XCTAssertNotNil(asset.URL);

        EndBlock();
    } failure:^(CDAResponse* response, NSError* error) {
        XCTFail(@"Error: %@", error);

        EndBlock();
    }];

    WaitUntilBlockCompletes();
}

-(void)testWildcardLocales {
    StartBlock();

    [self.client fetchEntriesMatching:@{ @"locale": @"*", @"sys.id": @"nyancat" }
                              success:^(CDAResponse* response, CDAArray* array) {
                                  NSLog(@"yolo: %@", array);

                                  EndBlock();
                              } failure:^(CDAResponse* response, NSError* error) {
                                  XCTFail(@"Error: %@", error);
                                  
                                  EndBlock();
                              }];
    
    WaitUntilBlockCompletes();
}

@end
