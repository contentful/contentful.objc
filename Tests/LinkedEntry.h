//
//  LinkedEntry.h
//  
//
//  Created by Boris Bügling on 24/09/15.
//
//

@import CoreData;
@import Foundation;

#import <ContentfulDeliveryAPI/CDAPersistedEntry.h>

@class LinkedEntry;

@interface LinkedEntry : NSManagedObject <CDAPersistedEntry>

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) LinkedEntry *link;
@property (nonatomic, retain) NSString * name;

@end
