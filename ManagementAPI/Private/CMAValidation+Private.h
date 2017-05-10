//
//  CMAValidation.h
//  Pods
//
//  Created by Boris Bügling on 17/11/14.
//
//

#import "CMAValidation.h"

@interface CMAValidation (Private)

-(NSDictionary*)dictionaryRepresentation;
-(instancetype)initWithDictionary:(NSDictionary*)validationDictionary;

@end
