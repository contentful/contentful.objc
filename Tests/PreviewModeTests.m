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
    
    self.client = [[CDAClient alloc] initWithSpaceKey:@"cfexampleapi" accessToken:@"5b5367a9a0cc3ab6ac2d4835bd8893907c61d3bafc7cb8b1f51840686a89fae3" configuration:configuration];
}

- (void)testReturnsUnpublishedContent {
    StartBlock();
    
    [self.client fetchEntriesMatching:@{ @"content_type": @"1t9IbcfdCk6m04uISSsaIK" }
                              success:^(CDAResponse *response, CDAArray* array) {
                                  XCTAssertEqual(6U, array.items.count, @"");
                                  
                                  BOOL foundEntries = NO;
                                  
                                  for (CDAEntry* entry in array.items) {
                                      if ([entry.identifier isEqualToString:@"6hIqDVkumASkySQg4gQsys"] || [entry.identifier isEqualToString:@"ebFIXyjSfuO42EMIWYGKK"]) {
                                          XCTAssertEqualObjects(@"Föö", entry.fields[@"name"], @"");
                                          
                                          foundEntries = YES;
                                      }
                                  }
                                  
                                  XCTAssertTrue(foundEntries, @"Expected Entries not found.");
                                  EndBlock();
                              } failure:^(CDAResponse *response, NSError *error) {
                                  XCTFail(@"Error: %@", error);
                                  
                                  EndBlock();
                              }];
    
    WaitUntilBlockCompletes();
}

@end
