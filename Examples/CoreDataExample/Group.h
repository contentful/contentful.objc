//
//  Group.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 03/09/14.
//
//

#import <ContentfulDeliveryAPI/CDAPersistedEntry.h>
#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>


@interface Group : NSManagedObject <CDAPersistedEntry>

@property (nonatomic, retain) NSString* identifier;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *members;

@end

