//
//  Asset.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 03/09/14.
//
//

#import <ContentfulDeliveryAPI/CDAPersistedAsset.h>
#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@interface Asset : NSManagedObject <CDAPersistedAsset>

@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * internetMediaType;
@property (nonatomic, retain) NSManagedObject *cat;
@property (nonatomic, retain) NSNumber * width;

@end
