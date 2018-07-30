//
//  CDARequestSerializer.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 21/07/14.
//
//

#import <AFNetworking/AFURLRequestSerialization.h>

@interface CDARequestSerializer : AFJSONRequestSerializer

@property (nonatomic) NSString* userAgent;

-(instancetype)initWithAccessToken:(NSString*)accessToken;
@end
