//
//  ManagedCatLocalized.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 14/04/14.
//
//

@import CoreData;
@import Foundation;

#import <ContentfulDeliveryAPI/CDALocalizedPersistedEntry.h>

@interface ManagedCatLocalized : NSManagedObject <CDALocalizedPersistedEntry>

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSNumber * livesLeft;

@end
