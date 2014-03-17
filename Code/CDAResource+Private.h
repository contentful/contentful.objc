//
//  CDAResource+Private.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAResource.h>

@class CDAClient;

@interface CDAResource ()

+(NSString*)CDAType;
+(instancetype)resourceObjectForDictionary:(NSDictionary*)dictionary client:(CDAClient*)client;

-(CDAClient*)client;
-(id)initWithDictionary:(NSDictionary*)dictionary client:(CDAClient*)client;
-(void)resolveLinksWithIncludedAssets:(NSDictionary*)assets entries:(NSDictionary*)entries;

@end
