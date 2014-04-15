//
//  SyncInfo.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 14/04/14.
//
//

#import <ContentfulDeliveryAPI/CDAPersistedSpace.h>
#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@interface SyncInfo : NSManagedObject <CDAPersistedSpace>

@property (nonatomic, retain) NSString * syncToken;
@property (nonatomic, retain) NSDate * lastSyncTimestamp;

@end
