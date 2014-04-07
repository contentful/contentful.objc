//
//  CDAEntry.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import "CDAClient+Private.h"
#import "CDAContentType.h"
#import "CDAContentTypeRegistry.h"
#import "CDAEntry.h"
#import "CDAFallbackDictionary.h"
#import "CDAField+Private.h"
#import "CDAResource+Private.h"
#import "CDASpace+Private.h"

@interface CDAEntry ()

@property (nonatomic) NSDictionary* localizedFields;

@end

#pragma mark -

@implementation CDAEntry

@synthesize locale = _locale;

#pragma mark -

+(NSString *)CDAType {
    return @"Entry";
}

#pragma mark -

-(CLLocationCoordinate2D)CLLocationCoordinate2DFromFieldWithIdentifier:(NSString*)identifier {
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = 0.0;
    coordinate.longitude = 0.0;
    
    if ([self.contentType fieldForIdentifier:identifier].type != CDAFieldTypeLocation) {
        [NSException raise:NSInvalidArgumentException format:@"Field %@ isn't a location.", identifier];
    }
    
    [self.fields[identifier] getBytes:&coordinate length:sizeof(coordinate)];
    return coordinate;
}

-(CDAContentType *)contentType {
    return self.sys[@"contentType"];
}

-(NSString *)description {
    /* Better than nothing, but has some \n and \t embedded because of 
     http://www.cocoabuilder.com/archive/cocoa/197297-who-broke-nslog-on-leopard.html#197302 */
    return [NSString stringWithFormat:@"CDAEntry %@ with fields:%@", self.identifier, self.fields];
}

-(NSDictionary *)fields {
    return self.localizedFields[self.locale];
}

-(id)initWithDictionary:(NSDictionary *)dictionary client:(CDAClient*)client {
    self = [super initWithDictionary:dictionary client:client];
    if (self && self.fetched) {
        NSAssert(self.contentType, @"Content-Type needs to be available.");
        
        Class customClass = [self.client.contentTypeRegistry customClassForContentType:self.contentType];
        if (customClass && customClass != [self class]) {
            return [[customClass alloc] initWithDictionary:dictionary client:client];
        }
        
        NSDictionary* fields = dictionary[@"fields"];
        NSMutableDictionary* localizedFields = [@{} mutableCopy];
        
        if (self.localizationAvailable) {
            NSDictionary* defaultDictionary = [self localizedDictionaryFromDictionary:fields forLocale:self.client.space.defaultLocale];
            localizedFields[self.client.space.defaultLocale] = defaultDictionary;
            
            for (NSString* locale in self.client.space.localeCodes) {
                if ([locale isEqualToString:self.client.space.defaultLocale]) {
                    continue;
                }
                
                NSDictionary* localizedDictionary = [self localizedDictionaryFromDictionary:fields
                                                                                  forLocale:locale];
                
                localizedFields[locale] = [[CDAFallbackDictionary alloc] initWithDictionary:localizedDictionary fallbackDictionary:defaultDictionary];
            }
        } else {
            localizedFields[self.client.space.defaultLocale] = [self parseDictionary:fields];
        }
        
        self.localizedFields = [localizedFields copy];
    }
    return self;
}

-(NSString *)locale {
    return _locale ?: self.client.space.defaultLocale;
}

-(NSDictionary *)localizedDictionaryFromDictionary:(NSDictionary *)dictionary
                                         forLocale:(NSString *)locale {
    NSDictionary* localizedDictionary = [super localizedDictionaryFromDictionary:dictionary
                                                                       forLocale:locale];
    return [self parseDictionary:localizedDictionary];
}

-(id)mapFieldsToObject:(NSObject*)object usingMapping:(NSDictionary*)dictionary {
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString* selfKeyPath,
                                                    NSString* objectKeyPath, BOOL *stop) {
        [object setValue:[self valueForKeyPath:selfKeyPath] forKeyPath:objectKeyPath];
    }];
    
    return object;
}

-(NSDictionary*)parseDictionary:(NSDictionary*)dictionary {
    NSMutableDictionary* fields = [@{} mutableCopy];
    
    NSAssert([dictionary isKindOfClass:[NSDictionary class]],
             @"Entry Fields are expected to be a dictionary.");
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString* key, id value, BOOL *stop) {
        CDAField* field = [self.contentType fieldForIdentifier:key];
        NSAssert(field, @"Entry contains unknown field '%@'.", key);
        
        id parsedValue = [field parseValue:value];
        if (parsedValue) {
            fields[key] = parsedValue;
        }
    }];
    
    return [fields copy];
}

-(NSDictionary*)resolveLinksInDictionary:(NSDictionary*)dictionary
                      withIncludedAssets:(NSDictionary*)assets
                                 entries:(NSDictionary*)entries {
    NSMutableDictionary* fields = [dictionary mutableCopy];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString* key, id value, BOOL *stop) {
        CDAField* field = [self.contentType fieldForIdentifier:key];
        
        if (field.type == CDAFieldTypeArray && [value isKindOfClass:[NSArray class]]) {
            NSArray* array = value;
            
            if (array.count > 0 && [[array firstObject] isKindOfClass:[CDAResource class]]) {
                NSMutableArray* newArray = [@[] mutableCopy];
                
                for (CDAResource* resource in array) {
                    CDAResource* possibleResource = [self resolveSingleResource:resource
                                                             withIncludedAssets:assets
                                                                        entries:entries];
                    [newArray addObject:possibleResource ?: resource];
                }
                
                fields[key] = [newArray copy];
            }
        }
        
        if (field.type == CDAFieldTypeLink && [value isKindOfClass:[CDAResource class]]) {
            CDAResource* possibleResource = [self resolveSingleResource:value
                                                     withIncludedAssets:assets
                                                                entries:entries];
            
            fields[key] = possibleResource ?: value;
        }
    }];
    
    return [fields copy];
}

-(void)resolveLinksWithIncludedAssets:(NSDictionary*)assets entries:(NSDictionary*)entries {
    NSMutableDictionary* localizedFields = [@{} mutableCopy];
    
    [self.localizedFields enumerateKeysAndObjectsUsingBlock:^(NSString* key,
                                                              NSDictionary* fields,
                                                              BOOL *stop) {
        localizedFields[key] = [self resolveLinksInDictionary:fields
                                           withIncludedAssets:assets
                                                      entries:entries];
    }];
    
    self.localizedFields = [localizedFields copy];
}

-(CDAResource*)resolveSingleResource:(CDAResource*)resource
               withIncludedAssets:(NSDictionary*)assets
                          entries:(NSDictionary*)entries {
    if (!resource.fetched) {
        NSString* linkType = resource.sys[@"linkType"];
        
        if ([linkType isEqualToString:@"Asset"]) {
            return assets[resource.identifier];
        }
        
        if ([linkType isEqualToString:@"Entry"]) {
            return entries[resource.identifier];
        }
    }
    
    return nil;
}

-(void)resolveWithSuccess:(void (^)(CDAResponse *, CDAResource *))success
                  failure:(void (^)(CDAResponse *, NSError *))failure {
    if (self.fetched) {
        [super resolveWithSuccess:success failure:failure];
        return;
    }
    
    [self.client fetchEntryWithIdentifier:self.identifier
                                  success:^(CDAResponse *response, CDAEntry *entry) {
                                      if (success) {
                                          success(response, entry);
                                      }
                                  } failure:failure];
}

-(void)setLocale:(NSString *)locale {
    if (_locale == locale) {
        return;
    }
    
    if ([self.localizedFields.allKeys containsObject:locale]) {
        _locale = locale;
    } else {
        _locale = self.client.space.defaultLocale;
    }
}

@end
