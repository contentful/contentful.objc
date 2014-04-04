//
//  CDASyncedSpace.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 25/03/14.
//
//

#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>

#import "CDAArray+Private.h"
#import "CDAClient+Private.h"
#import "CDADeletedAsset.h"
#import "CDADeletedEntry.h"
#import "CDARequestOperationManager.h"
#import "CDASyncedSpace+Private.h"

@interface CDASyncedSpace ()

@property (nonatomic) NSMutableArray* syncedAssets;
@property (nonatomic) NSMutableArray* syncedEntries;

@end

#pragma mark -

@implementation CDASyncedSpace

+(instancetype)shallowSyncSpaceWithToken:(NSString *)syncToken client:(CDAClient *)client {
    CDASyncedSpace* space = [[self class] new];
    space.client = client;
    space.nextSyncUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://example.com/foo?sync_token=%@", syncToken]];
    space.syncedAssets = nil;
    space.syncedEntries = nil;
    return space;
}

#pragma mark -

-(NSArray *)assets {
    return [self.syncedAssets copy];
}

-(NSArray *)entries {
    return [self.syncedEntries copy];
}

-(id)init {
    self = [super init];
    if (self) {
        self.syncedAssets = [@[] mutableCopy];
        self.syncedEntries = [@[] mutableCopy];
    }
    return self;
}

-(id)initWithAssets:(NSArray *)assets entries:(NSArray *)entries {
    self = [self init];
    if (self) {
        [self.syncedAssets addObjectsFromArray:assets];
        [self.syncedEntries addObjectsFromArray:entries];
    }
    return self;
}

-(void)performSynchronizationWithSuccess:(void (^)())success
                                 failure:(CDARequestFailureBlock)failure {
    NSParameterAssert(self.client);
    
    if (!self.syncToken) {
        if (failure) {
            failure(nil, [NSError errorWithDomain:CDAErrorDomain code:901 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"No sync token available.", nil) }]);
        }
        
        return;
    }
    
    [self.client.requestOperationManager fetchArrayAtURLPath:@"sync" parameters:@{ @"sync_token": self.syncToken } success:^(CDAResponse *response, CDAArray *array) {
        for (CDAResource* item in array.items) {
            if ([item isKindOfClass:[CDADeletedAsset class]]) {
                CDAAsset* deletedAsset = (CDAAsset*)item;
                
                for (CDAAsset* asset in self.syncedAssets) {
                    if ([asset.identifier isEqualToString:item.identifier]) {
                        deletedAsset = asset;
                        break;
                    }
                }
                
                if ([self.delegate respondsToSelector:@selector(syncedSpace:didDeleteAsset:)]) {
                    [self.delegate syncedSpace:self didDeleteAsset:deletedAsset];
                }
                
                [self willChangeValueForKey:@"assets"];
                [self.syncedAssets removeObject:deletedAsset];
                [self didChangeValueForKey:@"assets"];
            }
            
            if ([item isKindOfClass:[CDADeletedEntry class]]) {
                CDAEntry* deletedEntry = (CDAEntry*)item;
                
                for (CDAEntry* entry in self.syncedEntries) {
                    if ([entry.identifier isEqualToString:item.identifier]) {
                        deletedEntry = entry;
                        break;
                    }
                }
                
                if ([self.delegate respondsToSelector:@selector(syncedSpace:didDeleteEntry:)]) {
                    [self.delegate syncedSpace:self didDeleteEntry:deletedEntry];
                }
                
                [self willChangeValueForKey:@"entries"];
                [self.syncedEntries removeObject:deletedEntry];
                [self didChangeValueForKey:@"entries"];
            }
            
            if ([item isKindOfClass:[CDAAsset class]]) {
                [self willChangeValueForKey:@"assets"];
                
                NSUInteger assetIndex = [self.syncedAssets indexOfObject:item];
                if (assetIndex != NSNotFound) {
                    [self.syncedAssets replaceObjectAtIndex:assetIndex withObject:item];
                    
                    if ([self.delegate respondsToSelector:@selector(syncedSpace:didUpdateAsset:)]) {
                        [self.delegate syncedSpace:self didUpdateAsset:(CDAAsset*)item];
                    }
                } else {
                    [self.syncedAssets addObject:item];
                    
                    if ([self.delegate respondsToSelector:@selector(syncedSpace:didCreateAsset:)]) {
                        [self.delegate syncedSpace:self didCreateAsset:(CDAAsset*)item];
                    }
                }
                
                [self didChangeValueForKey:@"assets"];
            }
            
            if ([item isKindOfClass:[CDAEntry class]]) {
                [self willChangeValueForKey:@"entries"];
                
                NSUInteger entryIndex = [self.syncedEntries indexOfObject:item];
                if (entryIndex != NSNotFound) {
                    [self.syncedEntries replaceObjectAtIndex:entryIndex withObject:item];
                    
                    if ([self.delegate respondsToSelector:@selector(syncedSpace:didUpdateEntry:)]) {
                        [self.delegate syncedSpace:self didUpdateEntry:(CDAEntry*)item];
                    }
                } else {
                    [self.syncedEntries addObject:item];
                    
                    if ([self.delegate respondsToSelector:@selector(syncedSpace:didCreateEntry:)]) {
                        [self.delegate syncedSpace:self didCreateEntry:(CDAEntry*)item];
                    }
                }
                
                [self didChangeValueForKey:@"entries"];
            }
        }
        
        self.nextPageUrl = array.nextPageUrl;
        self.nextSyncUrl = array.nextSyncUrl;
        
        if (success) {
            if (self.nextPageUrl) {
                [self performSynchronizationWithSuccess:success failure:failure];
            } else {
                success();
            }
        }
    } failure:failure];
}

-(NSString *)syncToken {
    return [self syncTokenFromURL:self.nextPageUrl] ?: [self syncTokenFromURL:self.nextSyncUrl] ?: nil;
}

-(NSString*)syncTokenFromURL:(NSURL*)url {
    for (NSString* parameters in [url.query componentsSeparatedByString:@"&"]) {
        NSArray* query = [parameters componentsSeparatedByString:@"="];
        
        if ([[query firstObject] isEqualToString:@"sync_token"]) {
            return [query lastObject];
        }
    }
    
    return nil;
}

@end
