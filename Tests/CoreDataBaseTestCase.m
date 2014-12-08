//
//  CoreDataBaseTestCase.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 28/04/14.
//
//

#import "CoreDataBaseTestCase.h"
#import "CoreDataManager.h"

@implementation CoreDataBaseTestCase

-(CDAPersistenceManager*)createPersistenceManagerWithClient:(CDAClient*)client {
    if (self.query) {
        return [[CoreDataManager alloc] initWithClient:client
                                         dataModelName:@"CoreDataExample"
                                                 query:self.query];
    }

    return [[CoreDataManager alloc] initWithClient:client dataModelName:@"CoreDataExample"];
}

-(void)deleteStore {
    CoreDataManager* manager = (CoreDataManager*)self.persistenceManager;
    [[NSFileManager defaultManager] removeItemAtURL:manager.storeURL error:nil];
}

-(void)setUp {
    [super setUp];

    [self deleteStore];
}

-(void)tearDown {
    [super tearDown];

    [self deleteStore];
}

@end
