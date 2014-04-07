//
//  PersistenceTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 07/04/14.
//
//

#import "ContentfulBaseTestCase.h"

@interface PersistenceTests : ContentfulBaseTestCase

@property (nonatomic) NSURL* temporaryFileURL;

@end

#pragma mark -

@implementation PersistenceTests

-(void)setUp {
    [super setUp];
    
    NSString *fileName = [NSString stringWithFormat:@"%@_%@",
                          [[NSProcessInfo processInfo] globallyUniqueString], @"file.data"];
    self.temporaryFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory()
                                                    stringByAppendingPathComponent:fileName]];
}

-(void)testPersistEntry {
    StartBlock();
    
    [self.client fetchEntryWithIdentifier:@"nyancat" success:^(CDAResponse *response, CDAEntry *entry) {
        [entry writeToFile:self.temporaryFileURL.path];
        CDAEntry* readEntry = [CDAEntry readFromFile:self.temporaryFileURL.path
                                              client:self.client];
        
        XCTAssertEqualObjects(entry, readEntry, @"");
        XCTAssertEqualObjects(@"Entry", readEntry.sys[@"type"], @"");
        XCTAssertEqualObjects(@"nyancat", readEntry.identifier, @"");
        XCTAssertEqualObjects(@"nyancat", readEntry.sys[@"id"], @"");
        XCTAssertEqualObjects(@"Nyan Cat", readEntry.fields[@"name"], @"");
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

@end
