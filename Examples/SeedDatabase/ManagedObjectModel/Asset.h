//
//  Asset.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 03/09/14.
//
//

@import CoreData;
@import Foundation;

#import <ContentfulDeliveryAPI/CDAPersistedAsset.h>

@interface Asset : NSManagedObject <CDAPersistedAsset>

@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * internetMediaType;
@property (nonatomic, retain) NSManagedObject *cat;
@property (nonatomic, retain) NSNumber * width;

@end
