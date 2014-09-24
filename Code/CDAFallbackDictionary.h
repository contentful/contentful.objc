//
//  CDAFallbackDictionary.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 28/03/14.
//
//

@import Foundation;

@interface CDAFallbackDictionary : NSDictionary

-(id)initWithDictionary:(NSDictionary *)dict fallbackDictionary:(NSDictionary*)fallbackDict;

@end
