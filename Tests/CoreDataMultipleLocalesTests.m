//
//  CoreDataMultipleLocalesTests.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 22/09/15.
//
//

#import "CoreDataBaseTestCase.h"
#import "CoreDataManager.h"
#import "LocalizedCat.h"
#import "ManagedCatLocalized.h"
#import "SyncInfo.h"

@interface CoreDataMultipleLocalesTests : CoreDataBaseTestCase

@end

#pragma mark -

@implementation CoreDataMultipleLocalesTests

-(void)buildPersistenceManagerWithDefaultClient:(BOOL)defaultClient {
    [super buildPersistenceManagerWithDefaultClient:defaultClient];

    self.persistenceManager.classForAssets = [Asset class];
    self.persistenceManager.classForSpaces = [SyncInfo class];

    [self.persistenceManager setClass:[LocalizedCat class] forEntriesOfContentTypeWithIdentifier:@"cat"];
    [self.persistenceManager setClass:[ManagedCatLocalized class] forLocalizedEntriesOfContentTypeWithIdentifier:@"cat"];
}

-(CDAPersistenceManager*)createPersistenceManagerWithClient:(CDAClient*)client {
    return [[CoreDataManager alloc] initWithClient:client dataModelName:@"LocalizedModel"];
}

#pragma mark -

-(void)testMultipleLocales {
    [self removeAllStubs];
    [self buildPersistenceManagerWithDefaultClient:YES];

    StartBlock();

    [self.persistenceManager performSynchronizationWithSuccess:^{
        XCTAssertEqual(4U, [self.persistenceManager fetchAssetsFromDataStore].count, @"");
        XCTAssertEqual(3U, [self.persistenceManager fetchEntriesFromDataStore].count, @"");

        LocalizedCat* nyancat = (LocalizedCat*)[self.persistenceManager fetchEntryWithIdentifier:@"nyancat"];
        XCTAssertNotNil(nyancat, @"");
        XCTAssertNotNil(nyancat.picture);
        XCTAssertEqualObjects(nyancat.picture.url, @"https://images.ctfassets.net/cfexampleapi/4gp6taAwW4CmSgumq2ekUm/9da0cd1936871b8d72343e895a00d611/Nyan_cat_250px_frame.png", @"Unexpected url string for linked persistent asset.");
        for (ManagedCatLocalized* cat in nyancat.localizedEntries) {
            if ([cat.locale isEqualToString:@"en-US"]) {
                XCTAssertEqualObjects(@"Nyan Cat", cat.name, @"");
            } else if ([cat.locale isEqualToString:@"tlh"]) {
                XCTAssertEqualObjects(@"Nyan vIghro'", cat.name, @"");
            } else {
                XCTFail(@"Unexpected locale '%@'", cat.locale);
            }
        }

        EndBlock();
    } failure:^(CDAResponse *response, NSError *error) {
        XCTFail(@"Error: %@", error);

        EndBlock();
    }];

    WaitUntilBlockCompletes();
}

@end
