//
//  CDAFallbackDictionary.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 28/03/14.
//
//

@import Foundation;

@interface CDAFallbackDictionary : NSDictionary

-(instancetype)initWithDictionary:(NSDictionary *)dict fallbackDictionary:(NSDictionary*)fallbackDict;

@end
