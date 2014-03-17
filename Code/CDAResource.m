//
//  CDAResource.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAContentType.h>
#import <ContentfulDeliveryAPI/CDAResource.h>
#import <ContentfulDeliveryAPI/CDASpace.h>
#import <ISO8601DateFormatter/ISO8601DateFormatter.h>

#import "CDAClient+Private.h"
#import "CDAContentTypeRegistry.h"
#import "CDAResource+Private.h"
#import "CDAUtilities.h"

@interface CDAResource ()

@property (nonatomic, weak) CDAClient* client;
@property (nonatomic, readonly) BOOL isLink;
@property (nonatomic) NSDate* lastFetchedDate;
@property (nonatomic) NSDictionary* sys;

@end

#pragma mark -

@implementation CDAResource

+(instancetype)resourceObjectForDictionary:(NSDictionary *)dictionary client:(CDAClient*)client {
    NSString* resultType = dictionary[@"sys"][@"type"];
    
    BOOL isLink = [resultType isEqualToString:@"Link"];
    if (isLink) {
        resultType = dictionary[@"sys"][@"linkType"];
    }
    
    for (Class subclass in [self subclasses]) {
        if ([[subclass CDAType] isEqualToString:resultType]) {
            CDAResource* resource = [[subclass alloc] initWithDictionary:dictionary client:client];
            return resource;
        }
    }
    
    NSAssert(false, @"Unsupported result type '%@'", resultType);
    return nil;
}

+(NSArray*)subclasses {
    static dispatch_once_t once;
    static NSArray* subclasses;
    dispatch_once(&once, ^ { subclasses = CDAClassGetSubclasses([self class]); });
    return subclasses;
}

+(NSString*)CDAType {
    return nil;
}

#pragma mark -

-(BOOL)fetched {
    return self.lastFetchedDate != nil;
}

-(NSString *)identifier {
    return self.sys[@"id"];
}

-(id)initWithDictionary:(NSDictionary *)dictionary client:(CDAClient*)client {
    self = [super init];
    if (self) {
        NSParameterAssert(client);
        self.client = client;
        
        ISO8601DateFormatter* dateFormatter = [ISO8601DateFormatter new];
        NSMutableDictionary* systemProperties = [@{} mutableCopy];
        
        NSAssert(dictionary[@"sys"], @"A resource needs system properties");
        [dictionary[@"sys"] enumerateKeysAndObjectsUsingBlock:^(NSString* key, id value, BOOL *stop) {
            if ([@[ @"id", @"type" ] containsObject:key]) {
                NSAssert([value isKindOfClass:[NSString class]], @"id, type needs to be a string");
                systemProperties[key] = value;
            }
            
            if ([@[ @"revision" ] containsObject:key]) {
                NSAssert([value isKindOfClass:[NSNumber class]], @"revision needs to be a number");
                systemProperties[key] = value;
            }
            
            if ([@[ @"createdAt", @"updatedAt" ] containsObject:key]) {
                NSDate* date = [dateFormatter dateFromString:value];
                NSAssert(date, @"createdAt, updatedAt needs to be a valid date");
                systemProperties[key] = date;
            }
            
            if ([key isEqualToString:@"contentType"]) {
                NSString* contentTypeIdentifier = value[@"sys"][@"id"];
                CDAContentType* contentType = [self.client.contentTypeRegistry
                                               contentTypeForIdentifier:contentTypeIdentifier];
                NSAssert(contentType.name, @"Content-Type needs to be valid.");
                systemProperties[key] = contentType;
            }
            
            if ([key isEqualToString:@"space"]) {
                CDASpace* space = [[CDASpace alloc] initWithDictionary:value client:self.client];
                systemProperties[key] = space;
            }
        }];
        
        self.sys = systemProperties;
        self.lastFetchedDate = self.isLink ? nil : [NSDate date];
    }
    return self;
}

-(BOOL)isLink {
    return [self.sys[@"type"] isEqualToString:@"Link"];
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

@end
