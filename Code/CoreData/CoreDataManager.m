//
//  CoreDataManager.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 14/04/14.
//
//

#import <ContentfulDeliveryAPI/CDAAsset.h>
#import <ContentfulDeliveryAPI/CDAContentType.h>
#import <ContentfulDeliveryAPI/CDAEntry.h>
#import <CoreData/CoreData.h>

#import "CoreDataManager.h"

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
    return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self.classForAssets)
                                         inManagedObjectContext:self.managedObjectContext];
}

- (id<CDAPersistedEntry>)createPersistedEntryForContentTypeWithIdentifier:(NSString *)identifier
{
    Class entryClass = [self classForEntriesOfContentTypeWithIdentifier:identifier];
    if (!entryClass) {
        return nil;
    }
    return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(entryClass)
                                         inManagedObjectContext:self.managedObjectContext];
}

- (id<CDAPersistedSpace>)createPersistedSpace
{
    NSParameterAssert(self.classForSpaces);
    return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self.classForSpaces)
                                         inManagedObjectContext:self.managedObjectContext];
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

- (void)enumerateRelationshipsForClass:(Class)class usingBlock:(void (^)(NSString* relationshipName))block {
    NSParameterAssert(block);

    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:NSStringFromClass(class) inManagedObjectContext:self.managedObjectContext];

    NSArray* relationships = [entityDescription relationshipsByName].allKeys;
    [relationships enumerateObjectsUsingBlock:^(NSString* relationshipName, NSUInteger idx, BOOL *stop) {
        block(relationshipName);
    }];
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
                              error:(NSError**)error
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
    
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:NSStringFromClass(class)
                                              inManagedObjectContext:moc];
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

    return mapping;
}

- (void)performSynchronizationWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure {
    self.relationshipsToResolve = [@{} mutableCopy];
    
    [super performSynchronizationWithSuccess:success failure:failure];
}

- (void)resolveRelationships {
    for (id<CDAPersistedEntry> entry in [self fetchEntriesFromDataStore]) {
        NSDictionary* relationships = self.relationshipsToResolve[entry.identifier];
        [relationships enumerateKeysAndObjectsUsingBlock:^(NSString* keyPath, id value, BOOL *s) {
            if ([value isKindOfClass:[NSSet class]]) {
                NSMutableSet* resolvedSet = [NSMutableSet new];

                for (CDAResource* resource in value) {
                    [resolvedSet addObject:[self resolveResource:resource]];
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

    NSMutableDictionary* relationships = [@{} mutableCopy];

    [self enumerateRelationshipsForClass:persistedEntry.class usingBlock:^(NSString *relationshipName) {
        NSDictionary* mappingForEntries = [super mappingForEntriesOfContentTypeWithIdentifier:entry.contentType.identifier];
        NSString* entryKeyPath = [[mappingForEntries allKeysForObject:relationshipName] firstObject];

        if (!entryKeyPath) {
            return;
        }

        id relationshipTarget = [entry valueForKeyPath:entryKeyPath];

        if (!relationshipTarget) {
            return;
        }

        if ([relationshipTarget isKindOfClass:[NSArray class]]) {
            relationshipTarget = [NSSet setWithArray:relationshipTarget];
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
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle bundleForClass:[self class]]
                       URLForResource:self.dataModelName withExtension:@"momd"];
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
