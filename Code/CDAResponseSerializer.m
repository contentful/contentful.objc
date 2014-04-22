//
//  CDAResponseSerializer.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAArray.h>
#import <ContentfulDeliveryAPI/CDAConfiguration.h>
#import <ContentfulDeliveryAPI/CDAResource.h>

#import "CDAAsset.h"
#import "CDAClient+Private.h"
#import "CDAContentTypeRegistry.h"
#import "CDAEntry+Private.h"
#import "CDAResource+Private.h"
#import "CDAResponseSerializer.h"

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

-(BOOL)fetchContentTypesForJSONResponse:(id)JSONObject error:(NSError**)error {
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
        
        if (self.client.configuration.previewMode) {
            [acceptableContentTypes addObject:@"application/vnd.contentful.management.v1+json"];
        } else {
            [acceptableContentTypes addObject:@"application/vnd.contentful.delivery.v1+json"];
        }
        
        self.acceptableContentTypes = acceptableContentTypes;
    }
    return self;
}

-(id)responseObjectForResponse:(NSURLResponse *)response
                          data:(NSData *)data
                         error:(NSError **)error {
    id JSONObject = [super responseObjectForResponse:response data:data error:error];
    if (!JSONObject || ![JSONObject isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    if (![self fetchContentTypesForJSONResponse:JSONObject error:error]) {
        return nil;
    }
    
    self.client.synchronizing = JSONObject[@"nextPageUrl"] || JSONObject[@"nextSyncUrl"];
    
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
    
    NSAssert([JSONObject isKindOfClass:[NSDictionary class]], @"JSON result is not a dictionary");
    CDAResource* resource = [CDAResource resourceObjectForDictionary:JSONObject client:self.client];
    
    if ([resource isKindOfClass:[CDAArray class]]) {
        NSMutableArray* assetsToFetch = [@[] mutableCopy];
        NSMutableArray* entriesToFetch = [@[] mutableCopy];
        
        for (CDAResource* subResource in [(CDAArray*)resource items]) {
            if ([subResource isKindOfClass:[CDAAsset class]]) {
                assets[subResource.identifier] = subResource;
            }
            
            if ([subResource isKindOfClass:[CDAEntry class]]) {
                entries[subResource.identifier] = subResource;
                
                if (self.client.configuration.previewMode) {
                    CDAEntry* entry = (CDAEntry*)subResource;
                    [assetsToFetch addObjectsFromArray:[entry findUnresolvedAssets]];
                    [entriesToFetch addObjectsFromArray:[entry findUnresolvedEntries]];
                }
            }
        }
        
        if (self.client.configuration.previewMode && self.client.deepResolving) {
            self.client.deepResolving = NO;
            
            for (int i = 0; i < 10; i++) {
                NSArray* unresolvedAssetIds = [assetsToFetch valueForKey:@"identifier"];
                CDAArray* items = [self.client fetchAssetsMatching:@{ @"sys.id[in]": unresolvedAssetIds,
                                                                      @"limit": @(unresolvedAssetIds.count) }
                                            synchronouslyWithError:nil];
                
                for (CDAAsset* asset in items.items) {
                    assets[asset.identifier] = asset;
                }
                
                NSArray* unresolvedEntryIds = [entriesToFetch valueForKey:@"identifier"];
                items = [self.client fetchEntriesMatching:@{ @"sys.id[in]": unresolvedEntryIds,
                                                             @"limit": @(unresolvedEntryIds.count) }
                                   synchronouslyWithError:nil];
                
                [assetsToFetch removeAllObjects];
                [entriesToFetch removeAllObjects];
                
                for (CDAEntry* entry in items.items) {
                    entries[entry.identifier] = entry;
                    
                    [assetsToFetch addObjectsFromArray:[entry findUnresolvedAssets]];
                    [entriesToFetch addObjectsFromArray:[entry findUnresolvedEntries]];
                }
            }
            
            self.client.deepResolving = YES;
        }
    }
    
    for (CDAEntry* entry in entries.allValues) {
        [entry resolveLinksWithIncludedAssets:assets entries:entries];
    }
    
    [resource resolveLinksWithIncludedAssets:assets entries:entries];
    
    return resource;
}

@end
