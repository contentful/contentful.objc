//
//  Document.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 24/04/14.
//
//

@import CoreData;

#import <ContentfulDeliveryAPI/CDAPersistedEntry.h>

#import "Asset.h"

@interface Document : NSManagedObject <CDAPersistedEntry>

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * abstract;
@property (nonatomic, retain) Asset *thumbnail;
@property (nonatomic, retain) Asset *document;

@end
