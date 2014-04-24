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
            NSLog(@"Successfully generated your seed database.");
            
            [NSApp terminate:nil];
        } failure:^(CDAResponse *response, NSError *error) {
            NSLog(@"Error: %@", error);
            
            [NSApp terminate:nil];
        }];
        
        [NSApp run];
    }
    
    return 0;
}

