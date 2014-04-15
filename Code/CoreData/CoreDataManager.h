//
//  CoreDataManager.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 14/04/14.
//
//

#import <ContentfulDeliveryAPI/CDAPersistenceManager.h>

@interface CoreDataManager : CDAPersistenceManager

@property (nonatomic, readonly) NSURL* storeURL;

-(NSArray*)fetchAssetsFromDataStore;
-(NSArray*)fetchEntriesFromDataStore;
-(id)initWithClient:(CDAClient *)client dataModelName:(NSString*)dataModelName;

@end
