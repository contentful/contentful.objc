//
//  CDAFallbackDictionary.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 28/03/14.
//
//

#import <Foundation/Foundation.h>

@interface CDAFallbackDictionary : NSDictionary

-(id)initWithDictionary:(NSDictionary *)dict fallbackDictionary:(NSDictionary*)fallbackDict;

@end
