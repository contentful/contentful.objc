//
//  SyncInfo.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 14/04/14.
//
//

@import CoreData;
@import Foundation;

#import <ContentfulDeliveryAPI/CDAPersistedSpace.h>

@interface SyncInfo : NSManagedObject <CDAPersistedSpace>

@property (nonatomic, retain) NSString * syncToken;
@property (nonatomic, retain) NSDate * lastSyncTimestamp;

@end
