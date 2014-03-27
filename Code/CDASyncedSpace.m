//
//  CDASyncedSpace.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 25/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAAsset.h>
#import <ContentfulDeliveryAPI/CDAEntry.h>

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
    [self.client.requestOperationManager fetchArrayAtURLPath:@"sync" parameters:@{ @"sync_token": self.syncToken } success:^(CDAResponse *response, CDAArray *array) {
        for (CDAResource* item in array.items) {
            if ([item isKindOfClass:[CDADeletedAsset class]]) {
                for (CDAAsset* asset in self.syncedAssets) {
                    if ([asset.identifier isEqualToString:item.identifier]) {
                        [self.syncedAssets removeObject:asset];
                        
                        if ([self.delegate respondsToSelector:@selector(syncedSpace:didDeleteAsset:)]) {
                            [self.delegate syncedSpace:self didDeleteAsset:asset];
                        }
                        break;
                    }
                }
            }
            
            if ([item isKindOfClass:[CDADeletedEntry class]]) {
                for (CDAEntry* entry in self.syncedEntries) {
                    if ([entry.identifier isEqualToString:item.identifier]) {
                        [self.syncedEntries removeObject:entry];
                        
                        if ([self.delegate respondsToSelector:@selector(syncedSpace:didDeleteEntry:)]) {
                            [self.delegate syncedSpace:self didDeleteEntry:entry];
                        }
                        break;
                    }
                }
            }
            
            if ([item isKindOfClass:[CDAAsset class]]) {
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
            }
            
            if ([item isKindOfClass:[CDAEntry class]]) {
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
            }
        }
        
        self.nextPageUrl = array.nextPageUrl;
        self.nextSyncUrl = array.nextSyncUrl;
        
        if (success) {
            success();
        }
    } failure:failure];
}

-(NSString *)syncToken {
    for (NSString* parameters in [self.nextSyncUrl.query componentsSeparatedByString:@"&"]) {
        NSArray* query = [parameters componentsSeparatedByString:@"="];
        
        if ([[query firstObject] isEqualToString:@"sync_token"]) {
            return [query lastObject];
        }
    }
    
    return nil;
}

@end
