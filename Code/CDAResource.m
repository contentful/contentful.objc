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
#import <ISO8601DateFormatter/ISO8601DateFormatter.h>

#import "CDAClient+Private.h"
#import "CDAContentTypeRegistry.h"
#import "CDAInputSanitizer.h"
#import "CDAResource+Private.h"
#import "CDAUtilities.h"

// From: https://www.mikeash.com/pyblog/friday-qa-2010-06-18-implementing-equality-and-hashing.html
#define NSUINT_BIT (CHAR_BIT * sizeof(NSUInteger))
#define NSUINTROTATE(val, howmuch) ((((NSUInteger)val) << howmuch) | (((NSUInteger)val) >> (NSUINT_BIT - howmuch)))

typedef struct typeToClassMap_s {
    CFStringRef typeName;
    CFStringRef className;
} typeToClassMap_t;

static const typeToClassMap_t typeToClassMap[] = {
    { CFSTR("array"), CFSTR("CDAArray") },
    { CFSTR("asset"), CFSTR("CDAAsset") },
    { CFSTR("contenttype"), CFSTR("CDAContentType") },
    { CFSTR("deletedasset"), CFSTR("CDADeletedAsset") },
    { CFSTR("deletedentry"), CFSTR("CDADeletedEntry") },
    { CFSTR("entry"), CFSTR("CDAEntry") },
    { CFSTR("error"), CFSTR("CDAError") },
    { CFSTR("space"), CFSTR("CDASpace") },
};

@interface CDAResource ()

@property (nonatomic, readonly) BOOL isLink;
@property (nonatomic) NSDate* lastFetchedDate;
@property (nonatomic) NSDictionary* sys;

@end

#pragma mark -

@implementation CDAResource

+(BOOL)classIsOfType:(Class)otherClass {
    return CDAClassIsOfType(otherClass, self.class);
}

+(nullable instancetype)readFromFile:(NSString*)filePath client:(CDAClient*)client {
    if (filePath == nil) {
        return nil;
    }
    return [self readFromFileURL:[NSURL fileURLWithPath:filePath] client:client];
}

+(nullable instancetype)readFromFileURL:(NSURL*)fileURL client:(CDAClient*)client {
    return CDAReadItemFromFileURL(fileURL, client);
}

+(instancetype)resourceObjectForDictionary:(NSDictionary *)dictionary client:(CDAClient*)client {
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    dictionary = [CDAInputSanitizer sanitizeObject:dictionary];
    
    NSString* resourceType = dictionary[@"sys"][@"type"];
    
    BOOL isLink = [resourceType isEqualToString:@"Link"];
    if (isLink) {
        resourceType = dictionary[@"sys"][@"linkType"];
    }

    if (resourceType == nil) {
        NSAssert(false, @"No resource type given.");
        return nil;
    }
    resourceType = [resourceType lowercaseString];

    if (client.contentTypeRegistry.hasCustomClasses) {
        for (Class subclass in [self subclasses]) {
            // Avoid clashes with custom subclasses the user created
            if (![NSStringFromClass(subclass) hasPrefix:client.resourceClassPrefix]) {
                continue;
            }

            if ([[[subclass CDAType] lowercaseString] isEqualToString:resourceType]) {
                return [self resourceObjectForSubclass:subclass dictionary:dictionary client:client];
            }
        }
    } else {
        size_t const typeCount = sizeof(typeToClassMap) / sizeof(*typeToClassMap);
        for (size_t i = 0; i < typeCount; i++) {
            NSString * const name = (__bridge id) typeToClassMap[i].typeName;
            if ([name isEqualToString:resourceType]) {
                NSString * const className = (__bridge id) typeToClassMap[i].className;
                Class const subclass = NSClassFromString(className);
                return [self resourceObjectForSubclass:subclass dictionary:dictionary client:client];
            }
        }
    }
    
    NSAssert(false, @"Unsupported resource type '%@'", resourceType);
    return nil;
}

+(instancetype)resourceObjectForSubclass:(Class)subclass
                              dictionary:(NSDictionary *)dictionary
                                  client:(CDAClient *)client {
    CDAResource* resource = [[subclass alloc] initWithDictionary:dictionary client:client];
    if (!resource.fetched && client.configuration.filterNonExistingResources) {
        return nil;
    }
    return resource;
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
    NSString* identifier = self.sys[@"id"];
    NSParameterAssert(identifier);
    return identifier;
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
    NSString* resourceType = resource.sys[@"type"];
    NSString* resourceIdentifier = resource.identifier;

    if (!resourceIdentifier || !resourceType) {
        return false;
    }

    return [self.sys[@"type"] isEqualToString:resourceType] && [self.identifier isEqualToString:resourceIdentifier];
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
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self];
    [data writeToFile:filePath atomically:YES];
}

@end
