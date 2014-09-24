//
//  Group.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 03/09/14.
//
//

@import CoreData;
@import Foundation;

#import <ContentfulDeliveryAPI/CDAPersistedEntry.h>


@interface Group : NSManagedObject <CDAPersistedEntry>

@property (nonatomic, retain) NSString* identifier;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *members;

@end

