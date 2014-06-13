//
//  Asset.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 14/04/14.
//
//

#import <ContentfulDeliveryAPI/CDAPersistedAsset.h>
#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@interface Asset : NSManagedObject <CDAPersistedAsset>

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * internetMediaType;
@property (nonatomic, retain) NSManagedObject *cat;

@end
