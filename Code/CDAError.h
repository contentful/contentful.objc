//
//  CDAError.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 05/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAResource.h>

@interface CDAError : CDAResource

@property (nonatomic, readonly) NSDictionary* details;
@property (nonatomic, readonly) NSString* message;

+(NSError*)buildErrorWithCode:(NSInteger)code userInfo:(NSDictionary*)userInfo;

-(NSError*)errorRepresentationWithCode:(NSInteger)code;

@end
