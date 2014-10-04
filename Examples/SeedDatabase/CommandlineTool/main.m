//
//  main.m
//  ContentfulSeedDatabase
//
//  Created by Boris Bügling on 24/04/14.
//
//

@import Cocoa;

#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>

#import "CoreDataManager+SeedDB.h"

extern NSString* CDACacheDirectory();

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplicationLoad();
        
        CoreDataManager* manager = [CoreDataManager sharedManager];
        [manager performSynchronizationWithSuccess:^{
            NSArray* assets = [manager fetchAssetsFromDataStore];

            [assets enumerateObjectsUsingBlock:^(id<CDAPersistedAsset> asset,
                                                 NSUInteger idx,
                                                 BOOL *stop) {
                [CDAAsset cachePersistedAsset:asset
                                       client:manager.client
                             forcingOverwrite:NO
                            completionHandler:^(BOOL success) {
                                NSLog(@"Fetched asset from %@", asset.url);

                                if (idx == assets.count - 1) {
                                    NSLog(@"Successfully generated your seed database at '%@'",
                                          manager.storeURL.path);
                                    NSLog(@"Assets are stored at '%@'", CDACacheDirectory());

                                    [NSApp terminate:nil];
                                }
                            }];
            }];
        } failure:^(CDAResponse *response, NSError *error) {
            NSLog(@"Error: %@", error);
            
            [NSApp terminate:nil];
        }];
        
        [NSApp run];
    }
    
    return 0;
}

