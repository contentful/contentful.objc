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
@property (nonatomic, readonly) NSString* syncToken;

@end

#pragma mark -

@implementation CDASyncedSpace

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
    if (!self.syncToken) {
        if (failure) {
            failure(nil, [NSError errorWithDomain:CDAErrorDomain code:901 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"No sync token available.", nil) }]);
        }
        
        return;
    }
    
    [self.client.requestOperationManager fetchArrayAtURLPath:@"sync" parameters:@{ @"sync_token": self.syncToken } success:^(CDAResponse *response, CDAArray *array) {
        for (CDAResource* item in array.items) {
            if ([item isKindOfClass:[CDADeletedAsset class]]) {
                for (CDAAsset* asset in self.syncedAssets) {
                    if ([asset.identifier isEqualToString:item.identifier]) {
                        if ([self.delegate respondsToSelector:@selector(syncedSpace:didDeleteAsset:)]) {
                            [self.delegate syncedSpace:self didDeleteAsset:asset];
                        }
                        
                        [self willChangeValueForKey:@"assets"];
                        [self.syncedAssets removeObject:asset];
                        [self didChangeValueForKey:@"assets"];
                        break;
                    }
                }
            }
            
            if ([item isKindOfClass:[CDADeletedEntry class]]) {
                for (CDAEntry* entry in self.syncedEntries) {
                    if ([entry.identifier isEqualToString:item.identifier]) {
                        if ([self.delegate respondsToSelector:@selector(syncedSpace:didDeleteEntry:)]) {
                            [self.delegate syncedSpace:self didDeleteEntry:entry];
                        }
                        
                        [self willChangeValueForKey:@"entries"];
                        [self.syncedEntries removeObject:entry];
                        [self didChangeValueForKey:@"entries"];
                        break;
                    }
                }
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
