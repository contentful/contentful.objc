//
//  CoreDataBasicTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 15/04/14.
//
//

#import "ManagedCat.h"
#import "CoreDataManager.h"
#import "SyncBaseTestCase.h"
#import "SyncInfo.h"

@interface CoreDataBasicTests : SyncBaseTestCase

@property (nonatomic) CoreDataManager* coreDataManager;

@end

#pragma mark -

@implementation CoreDataBasicTests

-(void)setUp {
    [super setUp];
    
    self.coreDataManager = [[CoreDataManager alloc] initWithClient:self.client
                                                     dataModelName:@"CoreDataExample"];
    self.coreDataManager.classForEntries = [ManagedCat class];
    self.coreDataManager.classForSpaces = [SyncInfo class];
}

-(void)tearDown {
    [super tearDown];
    
    [[NSFileManager defaultManager] removeItemAtURL:self.coreDataManager.storeURL
                                              error:nil];
}

#pragma mark -

-(void)testInitialSync {
    StartBlock();
    
    [self.coreDataManager performSynchronizationWithSuccess:^{
        //XCTAssertEqual(2U, space.assets.count, @"");
        XCTAssertEqual(7U, [self.coreDataManager fetchEntriesFromDataStore].count, @"");
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

@end
