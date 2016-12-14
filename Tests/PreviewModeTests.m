//
//  PreviewModeTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 20/03/14.
//
//

#import "ContentfulBaseTestCase.h"

@interface PreviewModeTests : ContentfulBaseTestCase

@end

#pragma mark -

@implementation PreviewModeTests

- (void)setUp {
    [super setUp];
    
    CDAConfiguration* configuration = [CDAConfiguration defaultConfiguration];
    configuration.previewMode = YES;
    
    self.client = [[CDAClient alloc] initWithSpaceKey:@"cfexampleapi" accessToken:@"e5e8d4c5c122cf28fc1af3ff77d28bef78a3952957f15067bbc29f2f0dde0b50" configuration:configuration];
}

- (void)testAssetsInPreviewMode {
    StartBlock();
    
    [self.client fetchAssetWithIdentifier:@"nyancat" success:^(CDAResponse *response, CDAAsset *asset) {
        XCTAssertNotNil(asset.URL, @"");
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

- (void)testFetchLotsOfResources {
    StartBlock();
    
    CDAConfiguration* conf = [CDAConfiguration defaultConfiguration];
    conf.previewMode = YES;
    self.client = [[CDAClient alloc] initWithSpaceKey:@"fsnczri66h17" accessToken:@"30d6d8bfdbad6d49153573a97966a05287677abbb2ddc08118aab455e05bae11" configuration:conf];
    [self.client fetchAssetsWithSuccess:^(CDAResponse *response, CDAArray *array) {
                                  XCTAssertNotNil(array, @"");
                                  XCTAssertTrue(array.items.count > 0, @"");
                                  
                                  EndBlock();
                              } failure:^(CDAResponse *response, NSError *error) {
                                  XCTFail(@"Error: %@", error);
                                  
                                  EndBlock();
                              }];
    
    WaitUntilBlockCompletes();
}

// TODO: It looks like the cfexampleapi space content has changed and there is now no unpublished City.
//- (void)testReturnsUnpublishedContent {
//    StartBlock();
//    
//    [self.client fetchEntriesMatching:@{ @"content_type": @"1t9IbcfdCk6m04uISSsaIK" }
//                              success:^(CDAResponse *response, CDAArray* array) {
//                                  XCTAssertEqual(5U, array.items.count, @"");
//                                  
//                                  BOOL foundEntries = NO;
//                                  
//                                  for (CDAEntry* entry in array.items) {
//                                      if ([entry.identifier isEqualToString:@"4rPdazIwWkuuKEAQgemSmO"] || [entry.identifier isEqualToString:@"ebFIXyjSfuO42EMIWYGKK"]) {
//                                          XCTAssertEqualObjects(@"Test", entry.fields[@"name"], @"");
//                                          
//                                          foundEntries = YES;
//                                      }
//                                  }
//                                  
//                                  XCTAssertTrue(foundEntries, @"Expected Entries not found.");
//                                  EndBlock();
//                              } failure:^(CDAResponse *response, NSError *error) {
//                                  XCTFail(@"Error: %@", error);
//                                  
//                                  EndBlock();
//                              }];
//    
//    WaitUntilBlockCompletes();
//}

- (void)testRevisionFieldAccessible {
    StartBlock();
    
    [[CDAClient new] fetchEntryWithIdentifier:@"nyancat" success:^(CDAResponse *response,
                                                                   CDAEntry *entry) {
        NSNumber* revision = entry.sys[@"revision"];
        
        [self.client fetchEntryWithIdentifier:@"nyancat"
                                      success:^(CDAResponse *response, CDAEntry *entry) {
                                          XCTAssertNotNil(entry.sys[@"revision"], @"");
                                          XCTAssertEqualObjects(revision, entry.sys[@"revision"], @"");
                                          
                                          EndBlock();
                                      } failure:^(CDAResponse *response, NSError *error) {
                                          XCTFail(@"Error: %@", error);
                                          
                                          EndBlock();
                                      }];
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

@end
