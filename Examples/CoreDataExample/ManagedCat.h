//
//  ManagedCat.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 14/04/14.
//
//

#import <ContentfulDeliveryAPI/CDAPersistedEntry.h>
#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@class Asset;

@interface ManagedCat : NSManagedObject <CDAPersistedEntry>

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSNumber * livesLeft;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) Asset *picture;
@property (nonatomic, retain) NSNumber * deleted;

@end
