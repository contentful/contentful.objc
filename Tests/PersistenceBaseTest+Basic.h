//
//  PersistenceBaseTest+Basic.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 08/12/14.
//
//

#import "PersistenceBaseTest.h"

@interface PersistenceBaseTest (Basic)

-(void)basic_continueSyncFromDataStore;
-(void)basic_continueSyncWithSameManager;
-(void)basic_hasChanged;
-(void)basic_imageCaching;
-(void)basic_initialSync;
-(void)basic_relationships;
-(void)basic_setupFixtures;
-(void)basic_syncEmptyField;
-(void)basic_syncWithRepublishedEntries;

@end
