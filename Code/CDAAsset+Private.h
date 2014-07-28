//
//  CDAAsset+Private.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 05/03/14.
//
//

#import "CDAAsset.h"
#import "CDAPersistedAsset.h"

@interface CDAAsset ()

+(instancetype)assetFromPersistedAsset:(id<CDAPersistedAsset>)persistedAsset client:(CDAClient*)client;

-(NSDictionary*)localizedFields;
-(void)setValue:(id)value forFieldWithName:(NSString *)key;

@end
