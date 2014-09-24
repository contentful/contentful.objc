//
//  CDAFallbackDictionary.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 28/03/14.
//
//

#import "CDAFallbackDictionary.h"

@interface CDAFallbackDictionary ()

@property (nonatomic) NSDictionary* actualDictionary;
@property (nonatomic) NSDictionary* fallbackDictionary;
@property (nonatomic, readonly) NSSet* keySet;

@end

#pragma mark -

@implementation CDAFallbackDictionary

-(NSUInteger)count {
    return self.keySet.count;
}

-(id)initWithDictionary:(NSDictionary *)dict fallbackDictionary:(NSDictionary *)fallbackDict {
    self = [self initWithObjects:nil forKeys:nil count:0];
    if (self) {
        self.actualDictionary = dict;
        self.fallbackDictionary = fallbackDict;
    }
    return self;
}

-(instancetype)initWithObjects:(const __unsafe_unretained id [])objects
                       forKeys:(const __unsafe_unretained id<NSCopying> [])keys
                         count:(NSUInteger)cnt {
    self = [super init];
    return self;
}

-(NSEnumerator *)keyEnumerator {
    return [self.keySet objectEnumerator];
}

-(NSSet*)keySet {
    NSMutableSet* keySet = [NSMutableSet setWithArray:self.actualDictionary.allKeys];
    [keySet addObjectsFromArray:self.fallbackDictionary.allKeys];
    return [keySet copy];
}

-(id)objectForKey:(id)key {
    id value = [self.actualDictionary objectForKey:key];
    return value ?: [self.fallbackDictionary objectForKey:key];
}

@end
