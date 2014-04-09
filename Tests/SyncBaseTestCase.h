//
//  SyncBaseTestCase.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 09/04/14.
//
//

#import "ContentfulBaseTestCase.h"

@interface SyncBaseTestCase : ContentfulBaseTestCase <CDASyncedSpaceDelegate>

@property (nonatomic, readonly) BOOL contentTypesWereFetched;
@property (nonatomic) BOOL expectFieldsInDeletedResources;
@property (nonatomic, readonly) NSUInteger numberOfAssetsCreated;
@property (nonatomic, readonly) NSUInteger numberOfEntriesCreated;
@property (nonatomic, readonly) NSUInteger numberOfAssetsDeleted;
@property (nonatomic, readonly) NSUInteger numberOfEntriesDeleted;
@property (nonatomic, readonly) NSUInteger numberOfAssetsUpdated;
@property (nonatomic, readonly) NSUInteger numberOfEntriesUpdated;

-(void)addDummyContentType;
-(CDAClient*)buildClient;
-(CDAClient*)mockContentTypeRetrievalForClient:(CDAClient*)client;

@end
