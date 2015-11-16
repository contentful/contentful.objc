//
//  RealmManager.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 08/12/14.
//
//

#import <objc/runtime.h>
#import <Realm/Realm.h>

#import "CDAUtilities.h"
#import "RealmAsset.h"
#import "RealmManager.h"
#import "RealmSpace.h"

@interface RealmManager ()

@property (nonatomic, readonly) RLMRealm* currentRealm;
@property (nonatomic) NSMutableDictionary* relationshipsToResolve;

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
    self.relationshipsToResolve = [@{} mutableCopy];

    [self.currentRealm beginWriteTransaction];
    [super performSynchronizationWithSuccess:success failure:failure];
}

-(NSPredicate*)predicateWithIdentifier:(NSString*)identifier {
    return [NSPredicate predicateWithFormat:@"identifier = %@", identifier];
}

-(NSArray*)relationshipsForClass:(Class)clazz {
    unsigned int propCount = 0;
    objc_property_t* props = class_copyPropertyList(clazz, &propCount);

    NSMutableArray* relationships = [@[] mutableCopy];

    for (unsigned int i = 0; i < propCount; i++) {
        NSString* attributes = [[NSString alloc] initWithUTF8String:property_getAttributes(props[i])];
        if ([attributes hasPrefix:@"T@"]) {
            NSArray* attrs = [attributes componentsSeparatedByString:@"\""];
            if (attrs.count != 3) {
                continue;
            }

            Class propClass = NSClassFromString(attrs[1]);

            if (class_getSuperclass(propClass) != RLMObject.class) {
                continue;
            }

            [relationships addObject:[[NSString alloc] initWithUTF8String:property_getName(props[i])]];
        }
    }

    free(props);
    return relationships;
}

- (id)resolveResource:(CDAResource*)rsc {
    if (CDAClassIsOfType([rsc class], CDAAsset.class)) {
        return [self fetchAssetWithIdentifier:rsc.identifier];
    }

    if (CDAClassIsOfType([rsc class], CDAEntry.class)) {
        return [self fetchEntryWithIdentifier:rsc.identifier];
    }

    NSAssert(false, @"Unexpectly, %@ is neither an Asset nor an Entry.", rsc);
    return nil;
}

-(void)saveDataStore {
    for (id<CDAPersistedEntry> entry in [self fetchEntriesFromDataStore]) {
        NSDictionary* relationships = self.relationshipsToResolve[entry.identifier];

        [relationships enumerateKeysAndObjectsUsingBlock:^(NSString* keyPath, id value, BOOL *s) {
            value = [self resolveResource:value];

            [(NSObject*)entry setValue:value forKeyPath:keyPath];
        }];
    }

    [self.currentRealm commitWriteTransaction];
}

-(void)setClassForAssets:(Class)classForAssets {
    NSLog(@"%@ does not need a user-provided class for Assets.", NSStringFromClass(self.class));
}

-(void)setClassForSpaces:(Class)classForSpaces {
    NSLog(@"%@ does not need a user-provided class for Spaces.", NSStringFromClass(self.class));
}

-(void)updatePersistedEntry:(id<CDAPersistedEntry>)persistedEntry withEntry:(CDAEntry *)entry {
    [super updatePersistedEntry:persistedEntry withEntry:entry];

    Class clazz = [self classForEntriesOfContentTypeWithIdentifier:entry.contentType.identifier];
    NSMutableDictionary* relationships = [@{} mutableCopy];

    for (NSString* relationshipName in [self relationshipsForClass:clazz]) {
        NSDictionary* mappingForEntries = [super mappingForEntriesOfContentTypeWithIdentifier:entry.contentType.identifier];
        NSString* entryKeyPath = [[mappingForEntries allKeysForObject:relationshipName] firstObject];

        if (!entryKeyPath) {
            return;
        }

        id relationshipTarget = [entry valueForKeyPath:entryKeyPath];

        if (!relationshipTarget) {
            return;
        }

        relationships[relationshipName] = relationshipTarget;
    }

    self.relationshipsToResolve[entry.identifier] = [relationships copy];
}

@end
