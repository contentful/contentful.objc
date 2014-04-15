//
//  CoreDataBasicTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 15/04/14.
//
//

#import "Asset.h"
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
    self.coreDataManager.classForAssets = [Asset class];
    self.coreDataManager.classForEntries = [ManagedCat class];
    self.coreDataManager.classForSpaces = [SyncInfo class];
    
    self.coreDataManager.mappingForEntries = @{ @"contentType.identifier": @"contentTypeIdentifier",
                                                @"fields.color": @"color",
                                                @"fields.livesLeft": @"livesLeft",
                                                @"fields.name": @"name" };
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
        XCTAssertEqual(2U, [self.coreDataManager fetchAssetsFromDataStore].count, @"");
        XCTAssertEqual(7U, [self.coreDataManager fetchEntriesFromDataStore].count, @"");
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

-(void)testMappingOfFields {
    StartBlock();
    
    [self.coreDataManager performSynchronizationWithSuccess:^{
        NSString* predicate = @"contentTypeIdentifier == 'cat'";
        for (ManagedCat* cat in [self.coreDataManager fetchEntriesMatchingPredicate:predicate]) {
            XCTAssertNotNil(cat.color, @"");
            XCTAssertNotNil(cat.name, @"");
            XCTAssert(cat.livesLeft > 0, @"");
        }
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

@end
