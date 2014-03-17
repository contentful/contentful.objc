//
//  CDAField+Private.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAField.h>

@interface CDAField ()

-(id)initWithDictionary:(NSDictionary *)dictionary client:(CDAClient*)client;
-(id)parseValue:(id)value;

@end
