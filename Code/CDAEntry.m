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
#import "CDAField+Private.h"
#import "CDAResource+Private.h"

@interface CDAEntry ()

@property (nonatomic) NSDictionary* fields;

@end

#pragma mark -

@implementation CDAEntry

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

-(id)initWithDictionary:(NSDictionary *)dictionary client:(CDAClient*)client {
    self = [super initWithDictionary:dictionary client:client];
    if (self && self.fetched) {
        NSAssert(self.contentType, @"Content-Type needs to be available.");
        
        Class customClass = [self.client.contentTypeRegistry customClassForContentType:self.contentType];
        if (customClass && customClass != [self class]) {
            return [[customClass alloc] initWithDictionary:dictionary client:client];
        }
        
        NSMutableDictionary* fields = [@{} mutableCopy];
        
        [dictionary[@"fields"] enumerateKeysAndObjectsUsingBlock:^(NSString* key, id value, BOOL *stop) {
            CDAField* field = [self.contentType fieldForIdentifier:key];
            NSAssert(field, @"Entry contains unknown field '%@'.", key);
            
            id parsedValue = [field parseValue:value];
            if (parsedValue) {
                fields[key] = parsedValue;
            }
        }];
        
        self.fields = fields;
    }
    return self;
}

-(id)mapFieldsToObject:(NSObject*)object usingMapping:(NSDictionary*)dictionary {
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString* selfKeyPath,
                                                    NSString* objectKeyPath, BOOL *stop) {
        [object setValue:[self valueForKeyPath:selfKeyPath] forKeyPath:objectKeyPath];
    }];
    
    return object;
}

-(void)resolveLinksWithIncludedAssets:(NSDictionary*)assets entries:(NSDictionary*)entries {
    NSMutableDictionary* fields = [self.fields mutableCopy];
    
    [self.fields enumerateKeysAndObjectsUsingBlock:^(NSString* key, id value, BOOL *stop) {
        if ([value isKindOfClass:[CDAResource class]]) {
            if (![value fetched]) {
                CDAResource* possibleResource = assets[[value identifier]];
                if (possibleResource) {
                    fields[key] = possibleResource;
                }
                
                possibleResource = entries[[value identifier]];
                if (possibleResource) {
                    fields[key] = possibleResource;
                }
            }
        }
    }];
    
    self.fields = fields;
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

@end
