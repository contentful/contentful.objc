//
//  CoreDataManager+SeedDB.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 25/04/14.
//
//

#import "Asset.h"
#import "CoreDataManager+SeedDB.h"
#import "Document.h"
#import "SyncInfo.h"

/*
 This category is shared between the commandline tool and the iOS app to avoid code duplication.
 
 Change this to match the Space you want to generate a seed database for. You also need to modify the
 code to use the correct data model, managed object classes and mapping for Entries.
 
 When running the commandline tool, it will pre-populate an SQLite store with data and also fetch
 all available Assets to flat files. Those can be included in your bundle to make the app work offline
 from the start.
 */
static NSString* const CDAAccessToken   = @"a196a5806ddd5f25700624bb11dfc94aeac9f0a5d4bd245e68cf42f78f8b2cc6";
static NSString* const CDASpaceKey             = @"duzidfp33ikw";

@implementation CoreDataManager (SeedDB)

+(instancetype)sharedManager {
    static CoreDataManager *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        [self seedFromBundleWithInitialCacheDirectory:@"SeededAssets"];
        
        CDAClient* client = [[CDAClient alloc] initWithSpaceKey:CDASpaceKey accessToken:CDAAccessToken];
        
        _sharedManager = [[self alloc] initWithClient:client dataModelName:@"Doge"];
        
        _sharedManager.classForAssets = [Asset class];
        _sharedManager.classForSpaces = [SyncInfo class];

        [_sharedManager setClass:[Document class] forEntriesOfContentTypeWithIdentifier:@"1sBoLkeKjGmSeqOysqAICc"];
        
        [_sharedManager setMapping:@{ @"fields.abstract": @"abstract",
                                      @"fields.title": @"title",
                                      @"fields.document": @"document",
                                      @"fields.thumbnail": @"thumbnail" } forEntriesOfContentTypeWithIdentifier:@"1sBoLkeKjGmSeqOysqAICc"];
    });
    
    return _sharedManager;
}

@end
