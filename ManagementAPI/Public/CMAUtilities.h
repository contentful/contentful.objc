//
//  CMAUtilities.h
//  Pods
//
//  Created by Boris Bügling on 28/07/14.
//
//

#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation>
#endif


NSDictionary* CMASanitizeParameterDictionaryForJSON(NSDictionary* fields);
NSDictionary* CMATransformLocalizedFieldsToParameterDictionary(NSDictionary* localizedFields);
