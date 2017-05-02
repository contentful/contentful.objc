//
//  CDAFieldValueTransformer.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 09/03/14.
//
//

#import "CDAField.h"

@class CDAClient;

@interface CDAFieldValueTransformer : NSValueTransformer

@property (nonatomic) CDAFieldType itemType;

+(instancetype)transformerOfType:(CDAFieldType)type
                          client:(CDAClient*)client
           localizationAvailable:(BOOL)localizationAvailable;

@end
