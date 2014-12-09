//
//  ManagedRealmCat.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 08/12/14.
//
//

#import <ContentfulDeliveryAPI/CDAPersistedEntry.h>
#import <Realm/RLMObject.h>

#import "RealmAsset.h"

@interface ManagedRealmCat : RLMObject <CDAPersistedEntry>

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * color;
@property (nonatomic, assign) long livesLeft;
@property (nonatomic, strong) RealmAsset* picture;

@end
