//
//  CoreDataQuerySyncTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 28/04/14.
//
//

#import "CoreDataBaseTestCase.h"

@interface CoreDataQuerySyncTests : CoreDataBaseTestCase

@end

@implementation CoreDataQuerySyncTests

-(void)buildCoreDataManagerWithDefaultClient:(BOOL)defaultClient {
    self.client = [[CDAClient alloc] initWithSpaceKey:@"6mhvnnmyn9e1" accessToken:@"c054f8439246817a657ba7c5fa99989fa50db48c4893572d9537335b0c9b153e"];
    self.query = @{ @"content_type": @"6PnRGY1dxSUmaQ2Yq2Ege2" };
    
    [super buildCoreDataManagerWithDefaultClient:NO];
}

-(void)stubInitialRequestWithJSONNamed:(NSString*)initial updateWithJSONNamed:(NSString*)update {
    [self addRecordingWithJSONNamed:initial
                        inDirectory:@"QuerySync"
                            matcher:^BOOL(NSURLRequest *request) {
                                return [request.URL.absoluteString rangeOfString:@"entries"].location != NSNotFound && [request.URL.absoluteString rangeOfString:@"sys.updatedAt"].location == NSNotFound;
                            }];
    
    [self addRecordingWithJSONNamed:update
                        inDirectory:@"QuerySync"
                            matcher:^BOOL(NSURLRequest *request) {
                                return [request.URL.absoluteString rangeOfString:@"entries"].location != NSNotFound && [request.URL.absoluteString rangeOfString:@"sys.updatedAt"].location != NSNotFound;
                            }];
}

#pragma mark -

-(void)testInitialSync {
    StartBlock();
    
    [self.coreDataManager performSynchronizationWithSuccess:^{
        [self assertNumberOfAssets:1 numberOfEntries:2];
        
        for (ManagedCat* entry in [self.coreDataManager fetchEntriesFromDataStore]) {
            XCTAssertNotNil(entry.picture, @"");
            XCTAssertNotNil(entry.picture.url, @"");
        }
        
        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);
        
        EndBlock();
    }];
    
    WaitUntilBlockCompletes();
}

-(void)testAddEntry {
    [self stubInitialRequestWithJSONNamed:@"initial" updateWithJSONNamed:@"add-entry"];
    
    StartBlock();
    
    [self.coreDataManager performSynchronizationWithSuccess:^{
        [self assertNumberOfAssets:1 numberOfEntries:2];
        
        [self.coreDataManager performSynchronizationWithSuccess:^{
            [self assertNumberOfAssets:2 numberOfEntries:3];
            
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

-(void)testDeleteEntry {
    [self stubInitialRequestWithJSONNamed:@"initial" updateWithJSONNamed:@"delete-entry"];
    
    StartBlock();
    
    [self.coreDataManager performSynchronizationWithSuccess:^{
        [self assertNumberOfAssets:1 numberOfEntries:2];
        
        [self.coreDataManager performSynchronizationWithSuccess:^{
            [self assertNumberOfAssets:1 numberOfEntries:1];
            
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

-(void)testUpdateAsset {
    [self stubInitialRequestWithJSONNamed:@"initial2" updateWithJSONNamed:@"update-asset"];
    
    [self addRecordingWithJSONNamed:@"update-asset-assets"
                        inDirectory:@"QuerySync"
                            matcher:^BOOL(NSURLRequest *request) {
                                return [request.URL.absoluteString rangeOfString:@"assets"].location != NSNotFound;
                            }];
    
    StartBlock();
    
    [self.coreDataManager performSynchronizationWithSuccess:^{
        [self assertNumberOfAssets:1 numberOfEntries:2];
        
        id<CDAPersistedAsset> asset = [[self.coreDataManager fetchAssetsFromDataStore] firstObject];
        XCTAssertEqualObjects(@"3f5a00acf72df93528b6bb7cd0a4fd0c.jpeg",
                              asset.url.lastPathComponent, @"");
        
        [self.coreDataManager performSynchronizationWithSuccess:^{
            [self assertNumberOfAssets:1 numberOfEntries:2];
            XCTAssertNotEqualObjects(@"3f5a00acf72df93528b6bb7cd0a4fd0c.jpeg",
                                     asset.url.lastPathComponent, @"");
            
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
