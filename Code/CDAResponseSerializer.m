//
//  CDAResponseSerializer.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAConfiguration.h>
#import <ContentfulDeliveryAPI/CDAResource.h>

#import "CDAAsset.h"
#import "CDAClient+Private.h"
#import "CDAEntry.h"
#import "CDAResource+Private.h"
#import "CDAResponseSerializer.h"

@interface CDAResponseSerializer ()

@property (nonatomic, weak) CDAClient* client;

@end

#pragma mark -

@implementation CDAResponseSerializer

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
    if (!JSONObject) {
        return nil;
    }
    
    // TODO: Response can also contain errors, like nonResolvable.
    
    NSMutableDictionary* assets = [@{} mutableCopy];
    for (NSDictionary* possibleAsset in JSONObject[@"includes"][@"Asset"]) {
        CDAAsset* asset = [[CDAAsset alloc] initWithDictionary:possibleAsset client:self.client];
        assets[asset.identifier] = asset;
    }
    
    NSMutableDictionary* entries = [@{} mutableCopy];
    for (NSDictionary* possibleEntry in JSONObject[@"includes"][@"Entry"]) {
        CDAEntry* entry = [[CDAEntry alloc] initWithDictionary:possibleEntry client:self.client];
        entries[entry.identifier] = entry;
    }
    
    NSAssert([JSONObject isKindOfClass:[NSDictionary class]], @"JSON result is not a dictionary");
    CDAResource* resource = [CDAResource resourceObjectForDictionary:JSONObject client:self.client];
    [resource resolveLinksWithIncludedAssets:assets entries:entries];
    return resource;
}

@end
