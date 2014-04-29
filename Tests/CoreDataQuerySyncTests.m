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
    
    self.coreDataManager.trackDeletionsField = @"deleted";
}

-(void)stubInitialRequestWithJSONNamed:(NSString*)initial updateWithJSONNamed:(NSString*)update {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString rangeOfString:@"entries"].location != NSNotFound;
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        OHHTTPStubsResponse* response = nil;
        
        if ([request.URL.absoluteString rangeOfString:@"sys.updatedAt"].location == NSNotFound) {
            response = [self responseWithBundledJSONNamed:initial inDirectory:@"QuerySync"];
        } else {
            response = [self responseWithBundledJSONNamed:update inDirectory:@"QuerySync"];
        }
        
        response.responseTime = 1.0;
        return response;
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

@end
