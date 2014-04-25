//
//  main.m
//  ContentfulSeedDatabase
//
//  Created by Boris Bügling on 24/04/14.
//
//

#import <Cocoa/Cocoa.h>
#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>

#import "CoreDataManager+SeedDB.h"

extern NSString* CDACacheDirectory();
extern NSString* const CDASpaceKey;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplicationLoad();
        
        CoreDataManager* manager = [CoreDataManager sharedManager];
        [manager performSynchronizationWithSuccess:^{
            for (id<CDAPersistedAsset> asset in [manager fetchAssetsFromDataStore]) {
                NSLog(@"Fetching asset from %@", asset.url);
                NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:asset.url]];
                
                NSString* fileName = [NSString stringWithFormat:@"cache_%@_Asset_%@.data",
                                      CDASpaceKey, asset.identifier];
                fileName = [CDACacheDirectory() stringByAppendingPathComponent:fileName];
                [data writeToFile:fileName atomically:YES];
            }
            
            NSLog(@"Successfully generated your seed database at '%@'", manager.storeURL.path);
            NSLog(@"Assets are stored at '%@'", CDACacheDirectory());
            
            [NSApp terminate:nil];
        } failure:^(CDAResponse *response, NSError *error) {
            NSLog(@"Error: %@", error);
            
            [NSApp terminate:nil];
        }];
        
        [NSApp run];
    }
    
    return 0;
}

