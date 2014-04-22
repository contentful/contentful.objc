//
//  DeepIncludes.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 22/04/14.
//
//

#import "ContentfulBaseTestCase.h"

@interface DeepIncludes : ContentfulBaseTestCase

@end

#pragma mark -

@implementation DeepIncludes

- (void)setUp {
    [super setUp];
    
    CDAConfiguration* configuration = [CDAConfiguration defaultConfiguration];
    configuration.server = @"cdn.flinkly.com";
    
    self.client = [[CDAClient alloc] initWithSpaceKey:@"narx5fof1s82" accessToken:@"57f0a5ee7da0deda666a5f99c859b0e801bb452d08892950c61fa4a736913c13" configuration:configuration];
}

- (void)testDeepIncludesInsideIncludesInPreviewMode {
    StartBlock();
    
    CDAConfiguration* configuration = [CDAConfiguration defaultConfiguration];
    configuration.previewMode = YES;
    configuration.server = @"api.flinkly.com";
    
    self.client = [[CDAClient alloc] initWithSpaceKey:@"narx5fof1s82" accessToken:@"9e52c92213e27739490fe6edfde5a78bf6312d795be9d2c7d2ec948386d2a9a8" configuration:configuration];
    
    [self.client fetchEntriesMatching:@{ @"content_type": @"1JomZcABA4soOysGeE2QIE", @"include": @2 }
                              success:^(CDAResponse *response, CDAArray *array) {
                                  CDAEntry* exactEntry = nil;
                                  for (CDAEntry* entry in array.items) {
                                      if ([entry.identifier isEqualToString:@"4e1QYrwMwoksm4qmKUqskE"]) {
                                          exactEntry = entry;
                                          break;
                                      }
                                  }
                                  XCTAssertNotNil(exactEntry, @"");
                                  
                                  for (CDAEntry* entry in exactEntry.fields[@"cards"]) {
                                      if ([entry.identifier isEqualToString:@"3nYOvKqu2IsKCIwEoUE20e"]) {
                                          exactEntry = entry;
                                          break;
                                      }
                                  }
                                  
                                  CDAEntry* someEntry = [[exactEntry fields][@"locations"] firstObject];
                                  XCTAssertNotNil(someEntry, @"");
                                  XCTAssertNotNil(someEntry.fields, @"");
                                  
                                  EndBlock();
                              } failure:^(CDAResponse *response, NSError *error) {
                                  XCTFail(@"Error: %@", error);
                                  
                                  EndBlock();
                              }];
    
    WaitUntilBlockCompletes();
}

- (void)testDeepIncludesInsideIncludes {
    StartBlock();
    
    [self.client fetchEntriesMatching:@{ @"content_type": @"1JomZcABA4soOysGeE2QIE", @"include": @2 }
                              success:^(CDAResponse *response, CDAArray *array) {
                                  CDAEntry* exactEntry = nil;
                                  for (CDAEntry* entry in array.items) {
                                      if ([entry.identifier isEqualToString:@"4e1QYrwMwoksm4qmKUqskE"]) {
                                          exactEntry = entry;
                                          break;
                                      }
                                  }
                                  XCTAssertNotNil(exactEntry, @"");
                                  
                                  for (CDAEntry* entry in exactEntry.fields[@"cards"]) {
                                      if ([entry.identifier isEqualToString:@"3nYOvKqu2IsKCIwEoUE20e"]) {
                                          exactEntry = entry;
                                          break;
                                      }
                                  }
                                  
                                  CDAEntry* someEntry = [[exactEntry fields][@"locations"] firstObject];
                                  XCTAssertNotNil(someEntry, @"");
                                  XCTAssertNotNil(someEntry.fields, @"");
                                  
                                  EndBlock();
                              } failure:^(CDAResponse *response, NSError *error) {
                                  XCTFail(@"Error: %@", error);
                                  
                                  EndBlock();
                              }];
    
    WaitUntilBlockCompletes();
}

- (void)testDeepIncludesWithOneEntry {
    StartBlock();
    
    [self.client fetchEntriesMatching:@{ @"sys.id": @"3nYOvKqu2IsKCIwEoUE20e", @"include": @2 }
                              success:^(CDAResponse *response, CDAArray *array) {
                                  CDAEntry* exactEntry = [array.items firstObject];
                                  CDAEntry* someEntry = [[exactEntry fields][@"locations"] firstObject];
                                  XCTAssertNotNil(someEntry, @"");
                                  XCTAssertNotNil(someEntry.fields, @"");
                                  
                                  EndBlock();
                              } failure:^(CDAResponse *response, NSError *error) {
                                  XCTFail(@"Error: %@", error);
                                  
                                  EndBlock();
                              }];
    
    WaitUntilBlockCompletes();
}

- (void)testDeepIncludesWithMultipleEntries {
    StartBlock();
    
    [self.client fetchEntriesMatching:@{ @"include": @2 }
                              success:^(CDAResponse *response, CDAArray *array) {
                                  CDAEntry* exactEntry = nil;
                                  for (CDAEntry* entry in array.items) {
                                      if ([entry.identifier isEqualToString:@"3nYOvKqu2IsKCIwEoUE20e"]) {
                                          exactEntry = entry;
                                          break;
                                      }
                                  }
                                  XCTAssertNotNil(exactEntry, @"");
                                  
                                  CDAEntry* someEntry = [[exactEntry fields][@"locations"] firstObject];
                                  XCTAssertNotNil(someEntry, @"");
                                  XCTAssertNotNil(someEntry.fields, @"");
                                  
                                  EndBlock();
                              } failure:^(CDAResponse *response, NSError *error) {
                                  XCTFail(@"Error: %@", error);
                                  
                                  EndBlock();
                              }];
    
    WaitUntilBlockCompletes();
}

@end
