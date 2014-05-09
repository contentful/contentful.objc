//
//  CDAInputSanitizer.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 09/05/14.
//
//

#import "CDAInputSanitizer.h"

@implementation CDAInputSanitizer

+(NSArray*)sanitizeArray:(NSArray*)array {
    NSMutableArray* result = [array mutableCopy];
    
    [result removeObject:[NSNull null]];
    
    [array enumerateObjectsUsingBlock:^(id value, NSUInteger idx, BOOL *stop) {
        [result replaceObjectAtIndex:idx withObject:[self sanitizeObject:value]];
    }];
    
    return [result copy];
}

+(NSDictionary*)sanitizeDictionary:(NSDictionary*)dictionary {
    NSMutableDictionary* result = [dictionary mutableCopy];
    
    for (id key in dictionary.allKeys) {
        id value = result[key];
        
        if (value == [NSNull null]) {
            [result removeObjectForKey:key];
        } else {
            result[key] = [self sanitizeObject:value];
        }
    }
    
    return [result copy];
}

+(id)sanitizeObject:(id)object {
    if ([object isKindOfClass:[NSArray class]]) {
        return [self sanitizeArray:object];
    }
    
    if ([object isKindOfClass:[NSDictionary class]]) {
        return [self sanitizeDictionary:object];
    }
    
    return object;
}

@end
