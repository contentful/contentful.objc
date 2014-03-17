//
//  CDAFieldValueTransformer.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 09/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAField.h>

@class CDAClient;

@interface CDAFieldValueTransformer : NSValueTransformer

@property (nonatomic) CDAFieldType itemType;

+(instancetype)transformerOfType:(CDAFieldType)type client:(CDAClient*)client;

@end
