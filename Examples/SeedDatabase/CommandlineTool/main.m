//
//  main.m
//  ContentfulSeedDatabase
//
//  Created by Boris Bügling on 24/04/14.
//
//

#import <Cocoa/Cocoa.h>
#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>

#import "Asset.h"
#import "CoreDataManager.h"
#import "Document.h"
#import "SyncInfo.h"

extern NSString* CDACacheDirectory();

/*
 Change this to match the Space you want to generate a seed database for. You also need to modify the
 code to use the correct data model, managed object classes and mapping for Entries.
 
 When running the commandline tool, it will pre-populate an SQLite store with data and also fetch
 all available Assets to flat files. Those can be included in your bundle to make the app work offline
 from the start.
 */
static NSString* const CDAAccessToken   = @"a196a5806ddd5f25700624bb11dfc94aeac9f0a5d4bd245e68cf42f78f8b2cc6";
static NSString* const CDASpaceKey      = @"duzidfp33ikw";

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplicationLoad();
        
        CDAClient* client = [[CDAClient alloc] initWithSpaceKey:CDASpaceKey accessToken:CDAAccessToken];
        CoreDataManager* manager = [[CoreDataManager alloc] initWithClient:client dataModelName:@"Doge"];
        
        manager.classForAssets = [Asset class];
        manager.classForEntries = [Document class];
        manager.classForSpaces = [SyncInfo class];
        
        manager.mappingForEntries = @{ @"fields.abstract": @"abstract",
                                       @"fields.title": @"title",
                                       @"fields.document": @"document",
                                       @"fields.thumbnail": @"thumbnail" };
        
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

