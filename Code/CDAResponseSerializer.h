//
//  CDAResponseSerializer.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import <AFNetworking/AFURLResponseSerialization.h>

@interface CDAResponseSerializer : AFJSONResponseSerializer

-(id)initWithClient:(CDAClient*)client;

@end
