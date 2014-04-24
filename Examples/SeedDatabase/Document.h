//
//  Document.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 24/04/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <ContentfulDeliveryAPI/CDAPersistedEntry.h>

@interface Document : NSManagedObject <CDAPersistedEntry>

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * abstract;
@property (nonatomic, retain) NSManagedObject *thumbnail;
@property (nonatomic, retain) NSManagedObject *document;

@end
