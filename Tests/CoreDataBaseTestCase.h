//
//  CoreDataBaseTestCase.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 28/04/14.
//
//

#import "Asset.h"
#import "CoreDataManager.h"
#import "ManagedCat.h"
#import "SyncBaseTestCase.h"

@interface CoreDataBaseTestCase : SyncBaseTestCase

@property (nonatomic, readonly) CoreDataManager* coreDataManager;
@property (nonatomic) NSDictionary* query;

-(void)assertNumberOfAssets:(NSUInteger)numberOfAssets numberOfEntries:(NSUInteger)numberOfEntries;
-(void)buildCoreDataManagerWithDefaultClient:(BOOL)defaultClient;

@end
