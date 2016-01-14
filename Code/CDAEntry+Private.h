//
//  CDAEntry+Private.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAEntry.h>

@interface CDAEntry ()

-(NSArray*)findUnresolvedAssets;
-(NSArray*)findUnresolvedEntries;
-(NSDictionary*)localizedFields;
-(void)resolveLinksWithIncludedAssets:(NSDictionary*)assets
                              entries:(NSDictionary*)entries
                           usingBlock:(CDAResource* (^)(CDAResource* resource, NSDictionary* assets,
                                                        NSDictionary* entries))resolver;
-(void)setValue:(id)value forFieldWithName:(NSString *)key;

@end
