//
//  CDAResponseSerializer.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import <AFNetworking/AFURLResponseSerialization.h>

@interface CDAResponseSerializer : AFJSONResponseSerializer

@property (nonatomic, weak, readonly) CDAClient* client;

-(id)initWithClient:(CDAClient*)client;

@end
