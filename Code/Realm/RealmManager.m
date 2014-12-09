//
//  RealmManager.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 08/12/14.
//
//

#import <objc/runtime.h>
#import <Realm/Realm.h>

#import "RealmAsset.h"
#import "RealmManager.h"
#import "RealmSpace.h"

@interface RealmManager ()

@property (nonatomic, readonly) RLMRealm* currentRealm;

@end

#pragma mark -

@implementation RealmManager

-(Class)classForAssets {
    return [RealmAsset class];
}

-(Class)classForSpaces {
    return [RealmSpace class];
}

-(RLMRealm *)currentRealm {
    return [RLMRealm defaultRealm];
}

-(id<CDAPersistedAsset>)createPersistedAsset {
    id<CDAPersistedAsset> asset = [super createPersistedAsset];
    [self.currentRealm addObject:asset];
    return asset;
}

-(id<CDAPersistedEntry>)createPersistedEntryForContentTypeWithIdentifier:(NSString *)identifier {
    id<CDAPersistedEntry> entry = [super createPersistedEntryForContentTypeWithIdentifier:identifier];

    if (entry) {
        [self.currentRealm addObject:entry];
    }
    
    return entry;
}

-(id<CDAPersistedSpace>)createPersistedSpace {
    id<CDAPersistedSpace> space = [super createPersistedSpace];
    [self.currentRealm addObject:space];
    return space;
}

-(void)deleteAssetWithIdentifier:(NSString *)identifier {
    NSPredicate* predicate = [self predicateWithIdentifier:identifier];
    [self.currentRealm deleteObjects:[RealmAsset objectsWithPredicate:predicate]];
}

-(void)deleteEntryWithIdentifier:(NSString *)identifier {
    NSPredicate* predicate = [self predicateWithIdentifier:identifier];

    [self forEachEntryClassDo:^(__unsafe_unretained Class entryClass) {
        [self.currentRealm deleteObjects:[(id)entryClass objectsWithPredicate:predicate]];
    }];
}

-(NSArray *)fetchAssetsFromDataStore {
    NSMutableArray* assets = [@[] mutableCopy];
    for (RealmAsset* asset in [RealmAsset allObjects]) {
        [assets addObject:asset];
    }
    return [assets copy];
}

-(id<CDAPersistedAsset>)fetchAssetWithIdentifier:(NSString *)identifier {
    return [RealmAsset objectsWithPredicate:[self predicateWithIdentifier:identifier]].firstObject;
}

-(NSArray *)fetchEntriesFromDataStore {
    NSMutableArray* allEntries = [@[] mutableCopy];

    [self forEachEntryClassDo:^(__unsafe_unretained Class entryClass) {
        for (RLMObject* object in [(id)entryClass allObjects]) {
            [allEntries addObject:object];
        }
    }];

    return [allEntries copy];
}

-(id<CDAPersistedEntry>)fetchEntryWithIdentifier:(NSString *)identifier {
    __block id<CDAPersistedEntry> result = nil;
    NSPredicate* predicate = [self predicateWithIdentifier:identifier];

    [self forEachEntryClassDo:^(__unsafe_unretained Class entryClass) {
        RLMResults* results = [(id)entryClass objectsWithPredicate:predicate];
        if (results.count > 0) {
            result = results.firstObject;
        }
    }];

    return result;
}

-(id<CDAPersistedSpace>)fetchSpaceFromDataStore {
    return [RealmSpace allObjects].firstObject;
}

-(void)forEachEntryClassDo:(void (^)(Class entryClass))entryClassHandler {
    NSParameterAssert(entryClassHandler);

    NSMutableSet* classes = [NSMutableSet set];
    for (NSString* identifier in self.identifiersOfHandledContentTypes) {
        [classes addObject:[self classForEntriesOfContentTypeWithIdentifier:identifier]];
    }

    for (Class clazz in classes) {
        entryClassHandler(clazz);
    }
}

-(void)performSynchronizationWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure {
    [self.currentRealm beginWriteTransaction];
    [super performSynchronizationWithSuccess:success failure:failure];
}

-(NSPredicate*)predicateWithIdentifier:(NSString*)identifier {
    return [NSPredicate predicateWithFormat:@"identifier = %@", identifier];
}

-(void)saveDataStore {
    [self.currentRealm commitWriteTransaction];
}

-(void)setClassForAssets:(Class)classForAssets {
    NSLog(@"%@ does not need a user-provided class for Assets.", NSStringFromClass(self.class));
}

-(void)setClassForSpaces:(Class)classForSpaces {
    NSLog(@"%@ does not need a user-provided class for Spaces.", NSStringFromClass(self.class));
}

@end
