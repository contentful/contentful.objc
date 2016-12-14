//
//  SyncBaseTestCase.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 09/04/14.
//
//

#import <OCMock/OCMock.h>

#import "CDAClient+Private.h"
#import "CDADeletedAsset.h"
#import "CDADeletedEntry.h"
#import "CDAResource+Private.h"
#import "CDAUtilities.h"
#import "SyncBaseTestCase.h"

@interface SyncBaseTestCase ()

@property (nonatomic) BOOL contentTypesWereFetched;
@property (nonatomic) NSUInteger numberOfAssetsCreated;
@property (nonatomic) NSUInteger numberOfEntriesCreated;
@property (nonatomic) NSUInteger numberOfAssetsDeleted;
@property (nonatomic) NSUInteger numberOfEntriesDeleted;
@property (nonatomic) NSUInteger numberOfAssetsUpdated;
@property (nonatomic) NSUInteger numberOfEntriesUpdated;

@end

#pragma mark -

@implementation SyncBaseTestCase

-(void)addDummyContentType {
    CDAContentType* ct = [[CDAContentType alloc] initWithDictionary:@{ @"sys": @{ @"id": @"6bAvxqodl6s4MoKuWYkmqe" }, @"name": @"Stub", @"fields": @[ @{ @"id": @"title", @"type": @"Symbol" }, @{ @"id": @"body", @"type": @"Text" }, @{ @"id": @"category", @"type": @"Link" }, @{ @"id": @"picture", @"type": @"Link" } ] } client:self.client localizationAvailable:NO];
    ct = [[CDAContentType alloc] initWithDictionary:@{ @"sys": @{ @"id": @"51LZmvenywOe8aig28sCgY" }, @"name": @"OtherStub", @"fields": @[ @{ @"id": @"name", @"type": @"Symbol" } ], } client:self.client localizationAvailable:NO];
    ct = [[CDAContentType alloc] initWithDictionary:@{ @"sys": @{ @"id": @"4yCmJfmk1WeqACagaemOIs" }, @"name": @"AnotherStub", @"fields": @[ @{ @"id": @"link1", @"type": @"Link" }, @{ @"id": @"link2", @"type": @"Link" }, @{ @"id": @"link3", @"type": @"Link" } ], } client:self.client localizationAvailable:NO];
    ct = [[CDAContentType alloc] initWithDictionary:@{ @"sys": @{ @"id": @"5kLp8FbRwAG0kcOOYa6GMa" }, @"name": @"OtherStub", @"fields": @[ @{ @"id": @"suchField", @"type": @"Symbol" } ], } client:self.client localizationAvailable:NO];
}

-(CDAClient*)buildClient {
    self.client = [[CDAClient alloc] initWithSpaceKey:@"emh6o2ireilu" accessToken:@"1bf1261e0225089be464c79fff1a0773ca8214f1e82dd521f3ecf9690ba888ac"];
    [self setUpCCLRequestReplayForNSURLSession];
    return self.client;
}

-(CDAClient*)mockContentTypeRetrievalForClient:(CDAClient*)client {
    id partiallyMockedClient = [OCMockObject partialMockForObject:client];
    
    NSError *__autoreleasing *err = (NSError *__autoreleasing *)[OCMArg anyPointer];
    [[[(OCMockObject*)partiallyMockedClient stub] andDo:^(NSInvocation *invocation) {
        [self addDummyContentType];
        
        self.contentTypesWereFetched = YES;
        
        __unsafe_unretained NSDictionary* query;
        [invocation getArgument:&query atIndex:2];
        
        CDAArray* dummy = [CDAArray new];
        [dummy performSelector:@selector(setItems:) withObject:query[@"sys.id[in]"]];
        [invocation setReturnValue:&dummy];
        
        CFBridgingRetain(dummy);
        NSAssert(dummy.items.count > 0, @"Dummy is not set up correctly.");
    }] fetchContentTypesMatching:[OCMArg any] synchronouslyWithError:err];
    
    return partiallyMockedClient;
}

-(void)setUp {
    [super setUp];
    
    self.client = [self buildClient];
    self.contentTypesWereFetched = NO;
    
    self.numberOfAssetsCreated = 0;
    self.numberOfAssetsDeleted = 0;
    self.numberOfAssetsUpdated = 0;
    
    self.numberOfEntriesCreated = 0;
    self.numberOfEntriesDeleted = 0;
    self.numberOfEntriesUpdated = 0;
    
    [self addDummyContentType];
}

#pragma mark - CDASyncedSpaceDelegate

-(void)syncedSpace:(CDASyncedSpace *)space didCreateAsset:(CDAAsset *)asset {
    XCTAssert(CDAClassIsOfType([asset class], CDAAsset.class), @"");
    XCTAssertNotNil(asset.identifier, @"");
    XCTAssertNotNil(asset.fields, @"");
    
    self.numberOfAssetsCreated++;
}

-(void)syncedSpace:(CDASyncedSpace *)space didCreateEntry:(CDAEntry *)entry {
    XCTAssert(CDAClassIsOfType([entry class], CDAEntry.class), @"");
    XCTAssertNotNil(entry.identifier, @"");
    XCTAssertNotNil(entry.fields, @"");
    
    self.numberOfEntriesCreated++;
}

-(void)syncedSpace:(CDASyncedSpace *)space didDeleteAsset:(CDAAsset *)asset {
    XCTAssert((CDAClassIsOfType([asset class], CDAAsset.class) ||
              (CDAClassIsOfType([asset class], CDADeletedAsset.class))));
    XCTAssertNotNil(asset.identifier, @"");
    
    if (self.expectFieldsInDeletedResources) {
        XCTAssertNotNil(asset.fields, @"");
    }
    
    self.numberOfAssetsDeleted++;
}

-(void)syncedSpace:(CDASyncedSpace *)space didDeleteEntry:(CDAEntry *)entry {
    XCTAssert((CDAClassIsOfType([entry class], CDAEntry.class) ||
              CDAClassIsOfType([entry class], CDADeletedEntry.class)));
    XCTAssertNotNil(entry.identifier, @"");
    
    if (self.expectFieldsInDeletedResources) {
        XCTAssertNotNil(entry.fields, @"");
    }
    
    self.numberOfEntriesDeleted++;
}

-(void)syncedSpace:(CDASyncedSpace *)space didUpdateAsset:(CDAAsset *)asset {
    XCTAssert(CDAClassIsOfType([asset class], CDAAsset.class), @"");
    XCTAssertNotNil(asset.identifier, @"");
    XCTAssertNotNil(asset.fields, @"");
    
    self.numberOfAssetsUpdated++;
}

-(void)syncedSpace:(CDASyncedSpace *)space didUpdateEntry:(CDAEntry *)entry {
    XCTAssert(CDAClassIsOfType([entry class], CDAEntry.class));
    XCTAssertNotNil(entry.identifier, @"");
    XCTAssertNotNil(entry.fields, @"");
    
    self.numberOfEntriesUpdated++;
}

@end
