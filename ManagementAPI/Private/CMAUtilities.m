//
//  CMAUtilities.m
//  Pods
//
//  Created by Boris Bügling on 28/07/14.
//
//

#if __has_feature(modules)
@import MapKit;
#else
#import <MapKit/MapKit>
#endif

#import "CDAResource+Management.h"

static NSDateFormatter* dateFormatter = nil;

static id CMASanitizeParameterValue(id value) {
    if ([value isKindOfClass:[CDAResource class]]) {
        return [(CDAResource*)value linkDictionary];
    }

    if ([value isKindOfClass:[NSData class]]) {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(0.0, 0.0);
        [(NSData*)value getBytes:&coordinate length:sizeof(coordinate)];

        return @{ @"lon": @(coordinate.longitude), @"lat": @(coordinate.latitude) };
    }

    if ([value isKindOfClass:[NSDate class]]) {
        return [dateFormatter stringFromDate:(NSDate*)value];
    }

    if ([value isKindOfClass:[NSArray class]]) {
        NSMutableArray* result = [@[] mutableCopy];

        for (id item in value) {
            [result addObject:CMASanitizeParameterValue(item)];
        }

        return [result copy];
    }

    return value;
}

NSDictionary* CMASanitizeParameterDictionaryForJSON(NSDictionary* fields) {
    if (!dateFormatter) {
        dateFormatter = [NSDateFormatter new];
        NSLocale *posixLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormatter setLocale:posixLocale];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    }

    NSMutableDictionary* mutableFields = [NSMutableDictionary dictionaryWithDictionary:fields];

    [mutableFields enumerateKeysAndObjectsUsingBlock:^(NSString* key,
                                                       NSDictionary* localizedValues, BOOL *stop) {
        NSMutableDictionary* mutableLocalizedValues = [localizedValues mutableCopy];

        [localizedValues enumerateKeysAndObjectsUsingBlock:^(NSString* locale, id value, BOOL *stop) {
            mutableLocalizedValues[locale] = CMASanitizeParameterValue(value);
        }];

        mutableFields[key] = [mutableLocalizedValues copy];
    }];

    return mutableFields.count == 0 ? @{} : [mutableFields copy];
}

NSDictionary* CMATransformLocalizedFieldsToParameterDictionary(NSDictionary* localizedFields) {
    NSMutableDictionary* result = [@{} mutableCopy];

    [localizedFields enumerateKeysAndObjectsUsingBlock:^(NSString* language, NSDictionary* values,
                                                         BOOL *stop) {
        [values enumerateKeysAndObjectsUsingBlock:^(NSString* fieldName, id value, BOOL *stop) {
            NSMutableDictionary* fieldValues = result[fieldName] ?: [@{} mutableCopy];
            fieldValues[language] = value;
            result[fieldName] = fieldValues;
        }];
    }];

    return CMASanitizeParameterDictionaryForJSON(result);
}
