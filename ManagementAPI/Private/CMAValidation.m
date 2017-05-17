//
//  CMAValidation.m
//  Pods
//
//  Created by Boris Bügling on 17/11/14.
//
//

#import "CMAValidation+Private.h"

@interface CMAValidation ()

@property (nonatomic) NSDictionary* validation;

@end

#pragma mark -

@implementation CMAValidation

+(CMAValidation*)validationOfArraySizeWithMinimumValue:(NSNumber*)min maximumValue:(NSNumber*)max {
    NSMutableDictionary* params = [@{} mutableCopy];

    if (min) {
        params[@"min"] = min;
    }

    if (max) {
        params[@"max"] = max;
    }

    if (params.count == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:NSLocalizedString(@"Expected min and/or max boundaries", nil) userInfo:@{}];
    }

    return [[CMAValidation alloc] initWithDictionary:@{ @"size": params }];
}

+(CMAValidation*)validationOfLinksAgainstContentTypeIdentifiers:(NSArray*)contentTypeIds {
    NSParameterAssert(contentTypeIds);
    return [[CMAValidation alloc] initWithDictionary:@{ @"linkContentType": contentTypeIds }];
}

+(CMAValidation*)validationOfLinksAgainstMimeTypeGroup:(NSString*)group {
    NSParameterAssert(group);
    return [[CMAValidation alloc] initWithDictionary:@{ @"linkMimetypeGroup": group }];
}

+(CMAValidation*)validationOfRegularExpression:(NSString*)pattern flags:(NSString*)flags {
    NSParameterAssert(pattern);
    NSParameterAssert(flags);
    return [[CMAValidation alloc] initWithDictionary:@{ @"regexp": @{ @"pattern": pattern,
                                                                      @"flags": flags } }];
}

+(CMAValidation*)validationOfValueInArray:(NSArray*)valueArray {
    NSParameterAssert(valueArray);
    return [[CMAValidation alloc] initWithDictionary:@{ @"in": valueArray }];
}

+(CMAValidation*)validationOfValueRangeWithMinimumValue:(NSNumber*)min maximumValue:(NSNumber*)max {
    NSMutableDictionary* params = [@{} mutableCopy];

    if (min) {
        params[@"min"] = min;
    }

    if (max) {
        params[@"max"] = max;
    }

    if (params.count == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:NSLocalizedString(@"Expected min and/or max boundaries", nil) userInfo:@{}];
    }

    return [[CMAValidation alloc] initWithDictionary:@{ @"range": params }];
}

#pragma mark -

-(NSDictionary*)dictionaryRepresentation {
    return self.validation;
}

-(NSUInteger)hash {
    return [self.validation hash];
}

-(instancetype)initWithDictionary:(NSDictionary*)validationDictionary {
    self = [super init];
    if (self) {
        self.validation = validationDictionary;
    }
    return self;
}

-(BOOL)isEqual:(id)object {
    if (![object isKindOfClass:CMAValidation.class]) {
        return [super isEqual:object];
    }

    return [((CMAValidation*)object).validation isEqual:self.validation];
}

@end
