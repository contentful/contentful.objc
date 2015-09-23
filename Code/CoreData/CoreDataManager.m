//
//  CoreDataManager.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 14/04/14.
//
//

@import CoreData;

#import <ContentfulDeliveryAPI/CDAAsset.h>
#import <ContentfulDeliveryAPI/CDAContentType.h>
#import <ContentfulDeliveryAPI/CDAEntry.h>
#import <ContentfulDeliveryAPI/CDAField.h>

#import "CDAUtilities.h"
#import "CoreDataManager.h"

NSString* EntityNameFromClass(Class class) {
    NSString* entityName = NSStringFromClass(class);

    if ([entityName rangeOfString:@"."].location != NSNotFound) {
        NSArray* components = [entityName componentsSeparatedByString:@"."];
        NSCAssert(components.count == 2, @"Unexpected entity class name: %@", entityName);
        entityName = components[1];
    }

    return entityName;
}

@interface CoreDataManager ()

@property (nonatomic) NSString* dataModelName;
@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSManagedObjectModel *managedObjectModel;
@property (nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic) NSMutableDictionary* relationshipsToResolve;

@end

#pragma mark -

@implementation CoreDataManager

+ (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

+ (void)seedFromBundleWithInitialCacheDirectory:(NSString *)initialCacheDirectory
{
    [super seedFromBundleWithInitialCacheDirectory:initialCacheDirectory];
    
    NSArray* resources = [[NSBundle mainBundle] pathsForResourcesOfType:@"sqlite" inDirectory:nil];
    
    for (NSString* resource in resources) {
        NSString* target = [[self applicationDocumentsDirectory]
                            URLByAppendingPathComponent:resource.lastPathComponent].path;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:target]) {
            continue;
        }
        
        [[NSFileManager defaultManager] copyItemAtPath:resource toPath:target error:nil];
    }
}

#pragma mark -

- (id<CDAPersistedAsset>)createPersistedAsset
{
    NSParameterAssert(self.classForAssets);
    return [NSEntityDescription insertNewObjectForEntityForName:EntityNameFromClass(self.classForAssets)
                                         inManagedObjectContext:self.managedObjectContext];
}

- (id<CDAPersistedEntry>)createPersistedEntryForContentTypeWithIdentifier:(NSString *)identifier
{
    Class entryClass = [self classForEntriesOfContentTypeWithIdentifier:identifier];
    if (!entryClass) {
        return nil;
    }
    return [NSEntityDescription insertNewObjectForEntityForName:EntityNameFromClass(entryClass)
                                         inManagedObjectContext:self.managedObjectContext];
}

- (id<CDAPersistedSpace>)createPersistedSpace
{
    NSParameterAssert(self.classForSpaces);
    return [NSEntityDescription insertNewObjectForEntityForName:EntityNameFromClass(self.classForSpaces)
                                         inManagedObjectContext:self.managedObjectContext];
}

- (void)deleteAll {
    NSMutableArray* allFetchRequests = [@[] mutableCopy];

    [allFetchRequests addObject:[self fetchRequestForEntititiesOfClass:self.classForAssets
                                                    matchingPredicate:nil]];
    [allFetchRequests addObject:[self fetchRequestForEntititiesOfClass:self.classForSpaces
                                                    matchingPredicate:nil]];

    for (NSString* contentTypeIdentifier in self.identifiersOfHandledContentTypes) {
        Class c = [self classForEntriesOfContentTypeWithIdentifier:contentTypeIdentifier];
        NSFetchRequest* r = [self fetchRequestForEntititiesOfClass:c matchingPredicate:nil];
        [allFetchRequests addObject:r];
    }

    for (NSFetchRequest* request in allFetchRequests) {
        [request setIncludesPropertyValues:NO];
        [request setReturnsObjectsAsFaults:YES];

        for (NSManagedObject* obj in [self.managedObjectContext executeFetchRequest:request error:nil]) {
            [self.managedObjectContext deleteObject:obj];
        }
    }

    [self saveDataStore];
}

- (void)deleteAssetWithIdentifier:(NSString *)identifier
{
    id<CDAPersistedAsset> asset = [self fetchAssetWithIdentifier:identifier];
    
    if (asset) {
        [self.managedObjectContext deleteObject:asset];
    }
}

- (void)deleteEntryWithIdentifier:(NSString *)identifier
{
    id<CDAPersistedEntry> entry = [self fetchEntryWithIdentifier:identifier];
    
    if (entry) {
        [self.managedObjectContext deleteObject:entry];
    }
}

- (void)enumerateMappedFieldsForContentTypeWithIdentifier:(NSString*)identifier mapping:(NSDictionary*)mapping usingBlock:(void (^)(CDAContentType* contentType, CDAField* field, NSString* keyPath))block {
    NSParameterAssert(block);

    for (NSString* keyPath in mapping.allKeys) {
        NSArray* key = [keyPath componentsSeparatedByString:@"."];

        if (key.count != 2 || ![key[0] isEqualToString:@"fields"]) {
            continue;
        }

        [self.client fetchContentTypeWithIdentifier:identifier success:^(CDAResponse *response,
                                                                         CDAContentType *contentType) {
            CDAField* field = [contentType fieldForIdentifier:key[1]];
            if (field) {
                block(contentType, field, keyPath);
            }
        } failure:nil];
    }
}

- (void)enumerateRelationshipsForClass:(Class)class usingBlock:(void (^)(NSString* relationshipName))block {
    NSParameterAssert(block);

    NSEntityDescription* entityDescription = [self entityDescriptionForClass:class];

    NSArray* relationships = [entityDescription relationshipsByName].allKeys;
    [relationships enumerateObjectsUsingBlock:^(NSString* relationshipName, NSUInteger idx, BOOL *stop) {
        block(relationshipName);
    }];
}

- (NSEntityDescription*)entityDescriptionForClass:(Class)class {
    return [NSEntityDescription entityForName:EntityNameFromClass(class) inManagedObjectContext:self.managedObjectContext];
}

- (NSArray *)fetchAssetsFromDataStore
{
    NSError* error;
    NSArray* assets = [self fetchEntititiesOfClass:self.classForAssets
                                 matchingPredicate:nil
                                             error:&error];
    
    if (!assets) {
        NSLog(@"Could not fetch assets: %@", error);
    }
    
    return assets;
}

- (NSArray *)fetchAssetsMatchingPredicate:(NSString *)predicate
{
    NSError* error;
    NSArray* assets = [self fetchEntititiesOfClass:self.classForAssets
                                 matchingPredicate:predicate
                                             error:&error];
    
    if (!assets) {
        NSLog(@"Could not fetch assets: %@", error);
    }
    
    return assets;
}

- (id<CDAPersistedAsset>)fetchAssetWithIdentifier:(NSString *)identifier
{
    NSString* predicate = [NSString stringWithFormat:@"identifier == '%@'", identifier];
    return [[self fetchAssetsMatchingPredicate:predicate] firstObject];
}

- (NSArray *)fetchEntititiesOfClass:(Class)class
                  matchingPredicate:(NSString*)predicateString
                              error:(NSError* __autoreleasing *)error
{
    NSFetchRequest *request = [self fetchRequestForEntititiesOfClass:class
                                                   matchingPredicate:predicateString];
    return [self.managedObjectContext executeFetchRequest:request error:error];
}

- (NSArray *)fetchEntriesFromDataStore
{
    return [self fetchEntriesMatchingPredicate:nil];
}

- (NSArray *)fetchEntriesMatchingPredicate:(NSString *)predicate
{
    NSMutableSet* allEntries = [NSMutableSet new];

    for (NSString* identifier in self.identifiersOfHandledContentTypes) {
        NSArray* entries = [self fetchEntriesOfContentTypeWithIdentifier:identifier
                                                       matchingPredicate:predicate];
        [allEntries addObjectsFromArray:entries];
    }

    return allEntries.allObjects;
}

- (NSArray *)fetchEntriesOfContentTypeWithIdentifier:(NSString*)identifier
                                   matchingPredicate:(NSString *)predicate
{
    NSError* error;
    NSArray* entries = [self fetchEntititiesOfClass:[self classForEntriesOfContentTypeWithIdentifier:identifier] matchingPredicate:predicate error:&error];
    
    if (!entries) {
        NSLog(@"Could not fetch entries: %@", error);
    }
    
    return entries;
}

- (id<CDAPersistedEntry>)fetchEntryWithIdentifier:(NSString *)identifier
{
    NSString* predicate = [NSString stringWithFormat:@"identifier == '%@'", identifier];
    return [[self fetchEntriesMatchingPredicate:predicate] firstObject];
}

- (NSFetchRequest *)fetchRequestForEntititiesOfClass:(Class)class
                                   matchingPredicate:(NSString*)predicateString
{
    NSParameterAssert(class);
    
    NSFetchRequest *request = [NSFetchRequest new];

    NSEntityDescription *entityDescription = [self entityDescriptionForClass:class];
    [request setEntity:entityDescription];
    
    if (predicateString) {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:predicateString];
        [request setPredicate:predicate];
    }
    
    return request;
}

- (NSFetchRequest *)fetchRequestForEntriesOfContentTypeWithIdentifier:(NSString*)identifier
                                                    matchingPredicate:(NSString *)predicate
{
    Class class = [self classForEntriesOfContentTypeWithIdentifier:identifier];
    return [self fetchRequestForEntititiesOfClass:class matchingPredicate:predicate];
}

- (id<CDAPersistedSpace>)fetchSpaceFromDataStore
{
    NSError* error;
    NSArray* spaces = [self fetchEntititiesOfClass:self.classForSpaces
                                 matchingPredicate:nil
                                             error:&error];
    
    if (!spaces) {
        NSLog(@"Could not fetch space: %@", error);
    }
    
    return [spaces firstObject];
}

- (id)initWithClient:(CDAClient *)client dataModelName:(NSString*)dataModelName
{
    self = [super initWithClient:client];
    if (self) {
        NSParameterAssert(dataModelName);
        self.dataModelName = dataModelName;
    }
    return self;
}

- (id)initWithClient:(CDAClient *)client
       dataModelName:(NSString*)dataModelName
               query:(NSDictionary *)query
{
    self = [super initWithClient:client query:query];
    if (self) {
        NSParameterAssert(dataModelName);
        self.dataModelName = dataModelName;
    }
    return self;
}

- (id)initWithClient:(CDAClient *)client query:(NSDictionary *)query
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithClient:(CDAClient *)client
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSDictionary *)mappingForEntriesOfContentTypeWithIdentifier:(NSString *)identifier {
    NSMutableDictionary* mapping = [[super mappingForEntriesOfContentTypeWithIdentifier:identifier] mutableCopy];

    Class c = [self classForEntriesOfContentTypeWithIdentifier:identifier];
    [self enumerateRelationshipsForClass:c usingBlock:^(NSString *relationshipName) {
        for (NSString* key in [mapping allKeysForObject:relationshipName]) {
            [mapping removeObjectForKey:key];
        }
    }];

    [self enumerateMappedFieldsForContentTypeWithIdentifier:identifier mapping:mapping usingBlock:^(CDAContentType *contentType, CDAField *field, NSString *keyPath) {
        if (field.type == CDAFieldTypeArray) {
            if (field.itemType == CDAFieldTypeSymbol) {
                // Handled after the fact in updatePersistedEntry:withEntry:
                [mapping removeObjectForKey:keyPath];
            } else {
                [NSException raise:NSInvalidArgumentException format:@"Invalid mapping: field '%@' of Content Type '%@' is a list, but '%@' is not a relationship.", field.name, contentType.name, mapping[keyPath]];
            }
        }

        if (field.type == CDAFieldTypeLink) {
            [NSException raise:NSInvalidArgumentException format:@"Invalid mapping: field '%@' of Content Type '%@' is a link, but '%@' is not a relationship.", field.name, contentType.name, mapping[keyPath]];
        }
    }];

    return mapping;
}

- (void)performSynchronizationWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure {
    self.relationshipsToResolve = [@{} mutableCopy];
    
    [super performSynchronizationWithSuccess:success failure:failure];
}

- (NSRelationshipDescription*)relationshipDescriptionForName:(NSString*)relationshipName
                                                 entityClass:(Class)class {
    NSEntityDescription* entityDescription = [self entityDescriptionForClass:class];
    return entityDescription.relationshipsByName[relationshipName];
}

- (NSArray *)propertiesForEntriesOfContentTypeWithIdentifier:(NSString *)identifier {
    Class class = [self classForEntriesOfContentTypeWithIdentifier:identifier];
    NSEntityDescription* entityDescription = [self entityDescriptionForClass:class];
    return [entityDescription.properties valueForKey:@"name"];
}

- (void)resolveRelationships {
    for (id<CDAPersistedEntry> entry in [self fetchEntriesFromDataStore]) {
        NSDictionary* relationships = self.relationshipsToResolve[entry.identifier];
        [relationships enumerateKeysAndObjectsUsingBlock:^(NSString* keyPath, id value, BOOL *s) {
            NSRelationshipDescription* description = [self relationshipDescriptionForName:keyPath entityClass:entry.class];

            if ([value isKindOfClass:[NSOrderedSet class]] || [value isKindOfClass:[NSSet class]]) {
                id resolvedSet = description.isOrdered ? [NSMutableOrderedSet new] : [NSMutableSet new];

                for (CDAResource* resource in value) {
                    id resolvedResource = [self resolveResource:resource];
                    if (resolvedResource) {
                        [resolvedSet addObject:resolvedResource];
                    }
                }

                value = resolvedSet;
            } else {
                value = [self resolveResource:value];
            }

            [(NSObject*)entry setValue:value forKeyPath:keyPath];
        }];
    }
}

- (id)resolveResource:(CDAResource*)rsc {
    if ([rsc isKindOfClass:[CDAAsset class]]) {
        return [self fetchAssetWithIdentifier:rsc.identifier];
    }

    if ([rsc isKindOfClass:[CDAEntry class]]) {
        return [self fetchEntryWithIdentifier:rsc.identifier];
    }

    NSAssert(false, @"Unexpectly, %@ is neither an Asset nor an Entry.", rsc);
    return nil;
}

- (void)saveDataStore
{
    [self resolveRelationships];
    
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)updatePersistedEntry:(id<CDAPersistedEntry>)persistedEntry withEntry:(CDAEntry *)entry {
    [super updatePersistedEntry:persistedEntry withEntry:entry];

    NSDictionary* mappingForEntries = [super mappingForEntriesOfContentTypeWithIdentifier:entry.contentType.identifier];
    [self enumerateMappedFieldsForContentTypeWithIdentifier:entry.contentType.identifier mapping:mappingForEntries usingBlock:^(CDAContentType *contentType, CDAField *field, NSString *keyPath) {
        if (field.type == CDAFieldTypeArray && field.itemType == CDAFieldTypeSymbol) {
            NSString* key = mappingForEntries[keyPath];
            NSAttributeDescription* attributeDescription = [self entityDescriptionForClass:persistedEntry.class].attributesByName[key];

            if (attributeDescription.attributeType != NSBinaryDataAttributeType) {
                [NSException raise:NSInvalidArgumentException format:@"Invalid Core Data model: %@ needs to be of NSBinaryDataAttributeType.", attributeDescription.name];
            }

            NSArray* symbolArray = entry.fields[field.identifier];
            NSData* symbolArrayAsData = [NSKeyedArchiver archivedDataWithRootObject:symbolArray];
            [(NSObject*)persistedEntry setValue:symbolArrayAsData forKey:key];
        }
    }];

    NSMutableDictionary* relationships = [@{} mutableCopy];

    [self enumerateRelationshipsForClass:persistedEntry.class usingBlock:^(NSString *relationshipName) {
		NSRelationshipDescription* description = [self relationshipDescriptionForName:relationshipName entityClass:persistedEntry.class];
        NSString* entryKeyPath = [[mappingForEntries allKeysForObject:relationshipName] firstObject];

        if (!entryKeyPath) {
            return;
        }

        id relationshipTarget = [entry valueForKeyPath:entryKeyPath];

        if (!relationshipTarget) {
            return;
        }

        if ([relationshipTarget isKindOfClass:[NSArray class]]) {
			if (description.isOrdered) {
				relationshipTarget = [NSOrderedSet orderedSetWithArray:relationshipTarget];
			} else {
				relationshipTarget = [NSSet setWithArray:relationshipTarget];
			}
        } else {
            NSAssert([relationshipTarget isKindOfClass:[CDAResource class]],
                     @"Relationship target ought to be a Resource.");
        }
        
        relationships[relationshipName] = relationshipTarget;
    }];
    
    self.relationshipsToResolve[entry.identifier] = [relationships copy];
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        _managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }

    NSURL* modelURL = nil;
    for (NSBundle* bundle in @[ [NSBundle mainBundle], [NSBundle bundleForClass:self.class] ]) {
        modelURL = [bundle URLForResource:self.dataModelName withExtension:@"momd"];

        if (modelURL) {
            break;
        }
    }

    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:self.storeURL
                                                         options:nil
                                                           error:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSURL *)storeURL
{
    return [[[self class] applicationDocumentsDirectory] URLByAppendingPathComponent:[self.dataModelName stringByAppendingString:@".sqlite"]];
}

@end
