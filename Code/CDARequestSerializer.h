//
//  CDARequestSerializer.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 21/07/14.
//
//

#import "AFURLRequestSerialization.h"

@interface CDARequestSerializer : AFJSONRequestSerializer

-(id)initWithAccessToken:(NSString*)accessToken;

@end
