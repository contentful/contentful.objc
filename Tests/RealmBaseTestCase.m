//
//  RealmBaseTestCase.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 28/04/14.
//
//

#import <Realm/Realm.h>

#import "ManagedRealmCat.h"
#import "RealmBaseTestCase.h"
#import "RealmManager.h"

@implementation RealmBaseTestCase

-(void)setUp {
    [super setUp];

    [self deleteStore];
}

-(void)tearDown {
    [super tearDown];

    [self deleteStore];
}

-(void)buildPersistenceManagerWithDefaultClient:(BOOL)defaultClient {
    [super buildPersistenceManagerWithDefaultClient:defaultClient];

    NSArray* contentTypeIds = @[ @"1nGOrvlRTaMcyyq4IEa8ea",
                                 @"6bAvxqodl6s4MoKuWYkmqe",
                                 @"6PnRGY1dxSUmaQ2Yq2Ege2",
                                 @"cat"
                               ];

    Class c = [ManagedRealmCat class];
    for (NSString* contentTypeId in contentTypeIds) {
        [self.persistenceManager setClass:c forEntriesOfContentTypeWithIdentifier:contentTypeId];
    }
}

-(CDAPersistenceManager *)createPersistenceManagerWithClient:(CDAClient *)client {
    if (self.query) {
        return [[RealmManager alloc] initWithClient:client query:self.query];
    }

    return [[RealmManager alloc] initWithClient:client];
}

-(void)deleteStore {
    RLMRealm* realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteAllObjects];
    [realm commitWriteTransaction];
}


@end
