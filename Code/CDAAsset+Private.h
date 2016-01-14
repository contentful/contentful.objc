//
//  CDAAsset+Private.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 05/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAAsset.h>
#import <ContentfulDeliveryAPI/CDAPersistedAsset.h>

@interface CDAAsset ()

+(instancetype)assetFromPersistedAsset:(id<CDAPersistedAsset>)persistedAsset client:(CDAClient*)client;

-(NSDictionary*)localizedFields;
-(void)setValue:(id)value forFieldWithName:(NSString *)key;

@end
