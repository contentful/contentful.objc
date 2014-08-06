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

@property (nonatomic) NSString* name;
@property (nonatomic) CDAFieldType type;

-(id)initWithDictionary:(NSDictionary *)dictionary client:(CDAClient*)client;
-(id)parseValue:(id)value;

@end
