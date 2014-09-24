//
//  ManagedCat.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 14/04/14.
//
//

@import CoreData;
@import Foundation;

#import <ContentfulDeliveryAPI/CDAPersistedEntry.h>

@class Asset;

@interface ManagedCat : NSManagedObject <CDAPersistedEntry>

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSNumber * livesLeft;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) Asset *picture;

@end
