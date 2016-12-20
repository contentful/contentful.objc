//
//  CoreDataBaseTestCase.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 28/04/14.
//
//

#import "CoreDataBaseTestCase.h"
#import "CoreDataManager.h"
#import "SyncInfo.h"

@implementation CoreDataBaseTestCase

-(void)buildPersistenceManagerWithDefaultClient:(BOOL)defaultClient {
    [super buildPersistenceManagerWithDefaultClient:defaultClient];

    self.persistenceManager.classForAssets = [Asset class];
    self.persistenceManager.classForSpaces = [SyncInfo class];

    NSArray* contentTypeIds = @[ @"1nGOrvlRTaMcyyq4IEa8ea",
                                 @"6bAvxqodl6s4MoKuWYkmqe",
                                 @"6PnRGY1dxSUmaQ2Yq2Ege2",
                                 @"cat",
                                 @"test"
                               ];

    // FIXME: this is overriding content mappings done in super method call.
    Class c = [ManagedCat class];
    for (NSString* contentTypeId in contentTypeIds) {
        [self.persistenceManager setClass:c forEntriesOfContentTypeWithIdentifier:contentTypeId];
    }
}

-(CDAPersistenceManager*)createPersistenceManagerWithClient:(CDAClient*)client {

    // FIXME: Move to query related tests and out of base test class.
    if (self.query) {
        return [[CoreDataManager alloc] initWithClient:client
                                         dataModelName:@"CoreDataExample"
                                                 query:self.query];
    }

    return [[CoreDataManager alloc] initWithClient:client dataModelName:@"CoreDataExample"];
}

-(NSURL*)appendString:(NSString*)string toFileURL:(NSURL*)url {
    NSString* path = [url.path stringByAppendingString:string];
    return [NSURL fileURLWithPath:path];
}

-(void)deleteStore {
    CoreDataManager* manager = (CoreDataManager*)self.persistenceManager;

    if (![manager storeURL]) {
        return;
    }
    [[NSFileManager defaultManager] removeItemAtURL:manager.storeURL error:nil];

    NSURL* itemURL = [self appendString:@"-shm" toFileURL:manager.storeURL];
    [[NSFileManager defaultManager] removeItemAtURL:itemURL error:nil];

    itemURL = [self appendString:@"-wal" toFileURL:manager.storeURL];
    [[NSFileManager defaultManager] removeItemAtURL:itemURL error:nil];

    [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:3.0]];
}

@end
