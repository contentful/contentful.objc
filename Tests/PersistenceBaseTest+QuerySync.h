//
//  PersistenceBaseTest+QuerySync.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 08/12/14.
//
//

#import "PersistenceBaseTest.h"

@interface PersistenceBaseTest (QuerySync)

-(void)querySync_setupClient;

-(void)querySync_addEntry;
-(void)querySync_deleteEntry;
-(void)querySync_initial;
-(void)querySync_stubInitialRequestWithJSONNamed:(NSString*)initial updateWithJSONNamed:(NSString*)update;
-(void)querySync_updateAsset;
-(void)querySync_updateEntry;

@end
