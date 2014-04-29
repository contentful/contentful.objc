//
//  CDAEntry+Private.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import "CDAEntry.h"

@interface CDAEntry ()

-(NSArray*)findUnresolvedAssets;
-(NSArray*)findUnresolvedEntries;
-(void)resolveLinksWithIncludedAssets:(NSDictionary*)assets
                              entries:(NSDictionary*)entries
                           usingBlock:(CDAResource* (^)(CDAResource* resource, NSDictionary* assets,
                                                        NSDictionary* entries))resolver;

@end
