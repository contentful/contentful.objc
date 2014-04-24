//
//  CoreDataManager.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 14/04/14.
//
//

#import <ContentfulDeliveryAPI/CDAAsset.h>
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

- (id<CDAPersistedAsset>)createPersistedAsset
{
    NSParameterAssert(self.classForAssets);
    return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self.classForAssets)
                                         inManagedObjectContext:self.managedObjectContext];
}

- (id<CDAPersistedEntry>)createPersistedEntry
{
    NSParameterAssert(self.classForEntries);
    return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self.classForEntries)
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
    NSError* error;
    NSArray* entries = [self fetchEntititiesOfClass:self.classForEntries
                                  matchingPredicate:predicate
                                              error:&error];
    
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

- (NSFetchRequest *)fetchRequestForEntriesMatchingPredicate:(NSString *)predicate
{
    return [self fetchRequestForEntititiesOfClass:self.classForEntries matchingPredicate:predicate];
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
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)performSynchronizationWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure {
    self.relationshipsToResolve = [@{} mutableCopy];
    
    [super performSynchronizationWithSuccess:success failure:failure];
}

- (void)resolveRelationships {
    for (id<CDAPersistedEntry> entry in [self fetchEntriesFromDataStore]) {
        NSDictionary* relationships = self.relationshipsToResolve[entry.identifier];
        [relationships enumerateKeysAndObjectsUsingBlock:^(NSString* keyPath, CDAResource* rsc, BOOL *s) {
            if ([rsc isKindOfClass:[CDAAsset class]]) {
                id<CDAPersistedAsset> linkedAsset = [self fetchAssetWithIdentifier:rsc.identifier];
                [(NSObject*)entry setValue:linkedAsset forKeyPath:keyPath];
                return;
            }
            
            if ([rsc isKindOfClass:[CDAEntry class]]) {
                id<CDAPersistedEntry> linkedEntry = [self fetchEntryWithIdentifier:rsc.identifier];
                [(NSObject*)entry setValue:linkedEntry forKeyPath:keyPath];
                return;
            }
            
            NSAssert(false, @"Unexpectly, %@ is neither an Asset nor an Entry.", rsc);
        }];
    }
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
    
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:NSStringFromClass(persistedEntry.class) inManagedObjectContext:self.managedObjectContext];
    NSMutableDictionary* relationships = [@{} mutableCopy];
    
    for (NSString* relationshipName in [entityDescription relationshipsByName].allKeys) {
        NSString* entryKeyPath = [[self.mappingForEntries allKeysForObject:relationshipName] firstObject];
        
        CDAResource* resource = [entry valueForKeyPath:entryKeyPath];
        if (resource) {
            NSAssert([resource isKindOfClass:[CDAResource class]],
                     @"Relationship target ought to be a Resource.");
            relationships[relationshipName] = resource;
        }
    }
    
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
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[self.dataModelName stringByAppendingString:@".sqlite"]];
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

@end
