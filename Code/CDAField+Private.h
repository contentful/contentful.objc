//
//  CDAField+Private.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAField.h>

@class CDAClient;

@interface CDAField ()

-(NSString*)fieldTypeToString:(CDAFieldType)fieldType;
-(id)initWithDictionary:(NSDictionary *)dictionary client:(CDAClient*)client;
-(id)parseValue:(id)value;

@end
