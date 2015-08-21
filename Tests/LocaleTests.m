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
