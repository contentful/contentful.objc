//
//  CDAResource.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

@import ObjectiveC.runtime;

#import <ContentfulDeliveryAPI/CDAConfiguration.h>
#import <ContentfulDeliveryAPI/CDAContentType.h>
#import <ContentfulDeliveryAPI/CDAResource.h>
#import <ContentfulDeliveryAPI/CDASpace.h>
#import <HRCoder/HRCoder.h>
#import <ISO8601DateFormatter/ISO8601DateFormatter.h>

#import "CDAClient+Private.h"
#import "CDAContentTypeRegistry.h"
#import "CDAResource+Private.h"
#import "CDAUtilities.h"

// From: https://www.mikeash.com/pyblog/friday-qa-2010-06-18-implementing-equality-and-hashing.html
#define NSUINT_BIT (CHAR_BIT * sizeof(NSUInteger))
#define NSUINTROTATE(val, howmuch) ((((NSUInteger)val) << howmuch) | (((NSUInteger)val) >> (NSUINT_BIT - howmuch)))

@interface CDAResource ()

@property (nonatomic, readonly) BOOL isLink;
@property (nonatomic) NSDate* lastFetchedDate;
@property (nonatomic) NSDictionary* sys;

@end

#pragma mark -

@implementation CDAResource

+(BOOL)class:(Class)someClass isEqualToClass:(Class)otherClass {
    return [NSStringFromClass(someClass.class) isEqualToString:NSStringFromClass(otherClass.class)];
}

+(BOOL)classIsOfType:(Class)otherClass {
    do {
        if ([self class:self isEqualToClass:otherClass]) {
            return YES;
        }
    } while ((otherClass = class_getSuperclass(otherClass)));
    
    return NO;
}

+(instancetype)readFromFile:(NSString*)filePath client:(CDAClient*)client {
    CDAResource* item = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        item = [HRCoder unarchiveObjectWithData:[NSData dataWithContentsOfFile:filePath]];
    }
    
    item.client = client;
    return item;
}

+(instancetype)resourceObjectForDictionary:(NSDictionary *)dictionary client:(CDAClient*)client {
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSString* resourceType = dictionary[@"sys"][@"type"];
    
    BOOL isLink = [resourceType isEqualToString:@"Link"];
    if (isLink) {
        resourceType = dictionary[@"sys"][@"linkType"];
    }
    
    for (Class subclass in [self subclasses]) {
        // Avoid clashes with custom subclasses the user created
        if (![NSStringFromClass(subclass) hasPrefix:client.resourceClassPrefix]) {
            continue;
        }
        
        if ([[[subclass CDAType] lowercaseString] isEqualToString:[resourceType lowercaseString]]) {
            CDAResource* resource = [[subclass alloc] initWithDictionary:dictionary client:client];
            return resource;
        }
    }
    
    NSAssert(false, @"Unsupported resource type '%@'", resourceType);
    return nil;
}

+(NSArray*)subclasses {
    static dispatch_once_t once;
    static NSArray* subclasses;
    dispatch_once(&once, ^ { subclasses = CDAClassGetSubclasses([self class]); });
    return subclasses;
}

+(BOOL)supportsSecureCoding {
    return YES;
}

+(NSString*)CDAType {
    return nil;
}

#pragma mark -

-(BOOL)createdAfterDate:(NSDate *)date {
    return [(NSDate*)self.sys[@"createdAt"] compare:date] == NSOrderedDescending;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    CDAEncodeObjectWithCoder(self, aCoder);
}

-(BOOL)fetched {
    return self.lastFetchedDate != nil;
}

-(NSUInteger)hash {
    return NSUINTROTATE([self.identifier hash], NSUINT_BIT / 2) ^ [self.sys[@"type"] hash];
}

-(NSString *)identifier {
    return self.sys[@"id"];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        CDADecodeObjectWithCoder(self, aDecoder);
    }
    return self;
}

-(id)initWithDictionary:(NSDictionary *)dictionary client:(CDAClient*)client {
    self = [super init];
    if (self) {
        self.defaultLocaleOfSpace = @"en-US";

        [self updateWithContentsOfDictionary:dictionary client:client];

        NSParameterAssert(client);
        self.client = client;
    }
    return self;
}

-(BOOL)isEqual:(id)object {
    if ([object respondsToSelector:@selector(identifier)] &&
        [object respondsToSelector:@selector(sys)]) {
        return [self isEqualToResource:object];
    }
    return [super isEqual:object];
}

-(BOOL)isEqualToResource:(CDAResource*)resource {
    return [self.sys[@"type"] isEqualToString:resource.sys[@"type"]] && [self.identifier isEqualToString:resource.identifier];
}

-(BOOL)isLink {
    return [self.sys[@"type"] isEqualToString:@"Link"];
}

-(BOOL)localizationAvailable {
    return self.client.localizationAvailable;
}

-(NSDictionary*)localizedDictionaryFromDictionary:(NSDictionary*)dictionary forLocale:(NSString*)locale {
    NSParameterAssert(dictionary);
    NSParameterAssert(locale);
    
    NSMutableDictionary* result = [@{} mutableCopy];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* value, BOOL *stop) {
        id localizedValue = value[locale];
        
        if (!localizedValue) {
            return;
        }
        
        result[key] = localizedValue;
    }];
    
    return [result copy];
}

-(void)resolveLinksWithIncludedAssets:(NSDictionary*)assets entries:(NSDictionary*)entries {
}

-(void)resolveWithSuccess:(void (^)(CDAResponse *, CDAResource *))success
                  failure:(void (^)(CDAResponse *, NSError *))failure {
    if (self.fetched) {
        if (success) {
            success(nil, self);
        }
        
        return;
    }
    
    NSAssert(false, @"No known way to resolve a Resource of type %@", NSStringFromClass([self class]));
}

-(void)setClient:(CDAClient *)client {
    if (_client == client) {
        return;
    }
    
    _client = client;
    
    if (client.space.defaultLocale) {
        self.defaultLocaleOfSpace = client.space.defaultLocale;
    }
}

-(BOOL)updatedAfterDate:(NSDate *)date {
    return [(NSDate*)self.sys[@"updatedAt"] compare:date] == NSOrderedDescending;
}

-(void)updateWithContentsOfDictionary:(NSDictionary*)dictionary client:(CDAClient*)client {
    ISO8601DateFormatter* dateFormatter = [ISO8601DateFormatter new];
    NSMutableDictionary* systemProperties = [@{} mutableCopy];

    NSAssert(dictionary[@"sys"], @"A resource needs system properties");
    NSAssert([dictionary[@"sys"] isKindOfClass:[NSDictionary class]],
             @"Expected a dictionary of system properties");
    [dictionary[@"sys"] enumerateKeysAndObjectsUsingBlock:^(NSString* key, id value, BOOL *stop) {
        if ([@[ @"id", @"type", @"linkType" ] containsObject:key]) {
            NSAssert([value isKindOfClass:[NSString class]], @"%@ needs to be a string", key);
            systemProperties[key] = value;
        }

        if ([@[ @"revision", @"publishedCounter", @"version", @"archivedVersion",
                @"publishedVersion" ] containsObject:key]) {
            NSAssert([value isKindOfClass:[NSNumber class]], @"%@ needs to be a number", key);
            systemProperties[key] = value;
        }

        if ([@[ @"createdAt", @"updatedAt" ] containsObject:key]) {
            NSDate* date = [dateFormatter dateFromString:value];
            NSAssert(date, @"createdAt, updatedAt needs to be a valid date");
            systemProperties[key] = date;
        }

        if ([key isEqualToString:@"contentType"]) {
            NSString* contentTypeIdentifier = value[@"sys"][@"id"];
            CDAContentType* contentType = [client.contentTypeRegistry
                                           contentTypeForIdentifier:contentTypeIdentifier];
            NSAssert(contentType.name, @"Content-Type needs to be valid.");
            systemProperties[key] = contentType;
        }

        if ([key isEqualToString:@"space"]) {
            CDASpace* space = [[CDASpace alloc] initWithDictionary:value client:client];
            systemProperties[key] = space;
        }
    }];

    if (client.configuration.previewMode && systemProperties[@"publishedCounter"]) {
        systemProperties[@"revision"] = systemProperties[@"publishedCounter"];
    }

    self.sys = systemProperties;
    self.lastFetchedDate = self.isLink ? nil : [NSDate date];
}

-(void)updateWithResource:(CDAResource *)resource {
    if (!resource) {
        return;
    }

    NSMutableDictionary* systemProperties = [self.sys mutableCopy];

    for (NSString* key in @[ @"publishedCounter", @"version", @"archivedVersion", @"publishedVersion" ]) {
        id value = resource.sys[key];
        if (value) {
            systemProperties[key] = value;
        } else {
            [systemProperties removeObjectForKey:key];
        }
    }

    self.sys = systemProperties;
}

-(void)writeToFile:(NSString*)filePath {
    NSData* data = [HRCoder archivedDataWithRootObject:self];
    [data writeToFile:filePath atomically:YES];
}

@end
