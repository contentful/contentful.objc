//
//  CDAError.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 05/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAError.h>

@interface CDAError (Private)

+(NSError*)buildErrorWithCode:(NSInteger)code userInfo:(NSDictionary*)userInfo;

-(NSError*)errorRepresentationWithCode:(NSInteger)code;

@end
