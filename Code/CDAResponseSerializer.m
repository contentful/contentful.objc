//
//  CDAResponseSerializer.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAArray.h>
#import <ContentfulDeliveryAPI/CDAAsset.h>
#import <ContentfulDeliveryAPI/CDAResource.h>

#import "CDAClient+Private.h"
#import "CDAConfiguration+Private.h"
#import "CDAContentTypeRegistry.h"
#import "CDAEntry+Private.h"
#import "CDAOrganizationContainer.h"
#import "CDAResource+Private.h"
#import "CDAResponseSerializer.h"
#import "CDAUtilities.h"

@interface CDAResponseSerializer ()

@property (nonatomic, weak) CDAClient* client;

@end

#pragma mark -

@implementation CDAResponseSerializer

+(NSString*)contentTypeIdFromEntryDictionary:(NSDictionary*)entryDictionary {
    return entryDictionary[@"sys"][@"contentType"][@"sys"][@"id"];
}

-(NSArray*)unknownContentTypesInResult:(NSDictionary*)JSONObject {
    NSMutableSet* contentTypes = [NSMutableSet new];
    
    for (NSArray* possibleEntries in @[ JSONObject[@"includes"][@"Entry"] ?: @[],
                                        JSONObject[@"items"] ?: @[] ]) {
        for (NSDictionary* possibleEntry in possibleEntries) {
            NSString* possibleId = [[self class] contentTypeIdFromEntryDictionary:possibleEntry];
            if (possibleId && ![self.client.contentTypeRegistry contentTypeForIdentifier:possibleId]) {
                [contentTypes addObject:possibleId];
            }
        }
    }
    
    return [contentTypes allObjects];
}

#pragma mark -

-(BOOL)fetchContentTypesForJSONResponse:(id)JSONObject error:(NSError* __autoreleasing *)error {
    NSArray* contentTypeIds = [self unknownContentTypesInResult:JSONObject];
    
    if (contentTypeIds.count > 0) {
        CDAArray* contentTypes = [self.client fetchContentTypesMatching:@{@"sys.id[in]": contentTypeIds,
                                                                          @"limit": @(contentTypeIds.count)}
                                                 synchronouslyWithError:error];
        
        if (!contentTypes) {
            return NO;
        }
        
        NSAssert(contentTypeIds.count == contentTypes.items.count, @"Missing Content Types.");
    }
    
    return YES;
}

-(id)initWithClient:(CDAClient*)client {
    self = [super init];
    if (self) {
        self.client = client;
        
        NSMutableSet* acceptableContentTypes = [self.acceptableContentTypes mutableCopy];
        
        if (self.client.configuration.usesManagementAPI) {
            [acceptableContentTypes addObject:CMAContentTypeHeader];
        } else {
            [acceptableContentTypes addObject:CDAContentTypeHeader];
        }
        
        self.acceptableContentTypes = acceptableContentTypes;
    }
    return self;
}

-(NSArray*)fetchResources:(NSMutableArray*)unresolvedIds
            withBatchSize:(NSUInteger)batchSize
               fetchBlock:(CDAArray* (^)(NSDictionary* query))fetchBlock {
    NSMutableArray* batchedItems = [@[] mutableCopy];
    
    do {
        NSUInteger nextBatchLength = 0;
        
        if (unresolvedIds.count > batchSize) {
            nextBatchLength = batchSize;
        } else {
            nextBatchLength = unresolvedIds.count;
        }
        
        NSArray* batch = [unresolvedIds subarrayWithRange:NSMakeRange(0, nextBatchLength)];
        
        NSAssert(fetchBlock, @"You should pass a fetchBlock to this.");
        CDAArray* batchArray = fetchBlock(@{ @"sys.id[in]": batch, @"limit": @(batch.count) });
        [batchedItems addObjectsFromArray:batchArray.items];
        
        if (nextBatchLength < batchSize) {
            break;
        }
        
        [unresolvedIds removeObjectsInRange:NSMakeRange(0, nextBatchLength)];
    } while (YES);
    
    return [batchedItems copy];
}

-(id)responseObjectForResponse:(NSURLResponse *)response
                          data:(NSData *)data
                         error:(NSError * __autoreleasing *)error {
    id JSONObject = data.length > 0 ? [super responseObjectForResponse:response
                                                                  data:data
                                                                 error:error] : nil;
    if (!JSONObject || ![JSONObject isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    if (![self fetchContentTypesForJSONResponse:JSONObject error:error]) {
        return nil;
    }
    
    self.client.synchronizing = JSONObject[@"nextPageUrl"] || JSONObject[@"nextSyncUrl"] || [CDAValueForQueryParameter(response.URL, @"locale") isEqualToString:@"*"];
    
    NSMutableDictionary* assets = [@{} mutableCopy];
    for (NSDictionary* possibleAsset in JSONObject[@"includes"][@"Asset"]) {
        CDAAsset* asset = [[CDAAsset alloc] initWithDictionary:possibleAsset client:self.client];
        assets[asset.identifier] = asset;
    }
    
    NSMutableDictionary* entries = [@{} mutableCopy];
    for (NSDictionary* possibleEntry in JSONObject[@"includes"][@"Entry"]) {
        CDAEntry* entry = [[CDAEntry alloc] initWithDictionary:possibleEntry client:self.client];
        [entry resolveLinksWithIncludedAssets:assets entries:nil];
        entries[entry.identifier] = entry;
    }

    NSMutableArray* organizations = [@[] mutableCopy];
    for (NSDictionary* possibleOrganization in JSONObject[@"includes"][@"Organization"]) {
        CDAResource* resource = [CDAResource resourceObjectForDictionary:possibleOrganization
                                                                  client:self.client];
        [organizations addObject:resource];
    }
    
    NSAssert([JSONObject isKindOfClass:[NSDictionary class]], @"JSON result is not a dictionary");
    CDAResource* resource = [CDAResource resourceObjectForDictionary:JSONObject client:self.client];
    
    if (CDAClassIsOfType([resource class], CDAArray.class)) {
        for (CDAResource* subResource in [(CDAArray*)resource items]) {
            if (CDAClassIsOfType([subResource class], CDAAsset.class)) {
                assets[subResource.identifier] = subResource;
            }
            
            if (CDAClassIsOfType([subResource class], CDAEntry.class)) {
                entries[subResource.identifier] = subResource;
            }

            if ([subResource conformsToProtocol:@protocol(CDAOrganizationContainer)]) {
                [(id<CDAOrganizationContainer>)subResource setOrganizations:organizations];
            }
        }
    }

    if ([resource conformsToProtocol:@protocol(CDAOrganizationContainer)]) {
        [(id<CDAOrganizationContainer>)resource setOrganizations:organizations];
    }
    
    for (CDAEntry* entry in entries.allValues) {
        [entry resolveLinksWithIncludedAssets:assets entries:entries];
    }
    
    [resource resolveLinksWithIncludedAssets:assets entries:entries];
    
    return resource;
}

@end
