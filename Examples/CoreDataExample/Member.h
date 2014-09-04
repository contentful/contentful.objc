//
//  Member.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 03/09/14.
//
//

#import <ContentfulDeliveryAPI/CDAPersistedEntry.h>
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Group;

@interface Member : NSManagedObject <CDAPersistedEntry>

@property (nonatomic, retain) NSString* identifier;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) Group *group;

@end
