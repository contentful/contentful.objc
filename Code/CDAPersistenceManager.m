//
//  CDAPersistenceManager.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 15/04/14.
//
//

@import ObjectiveC.runtime;

#import <ContentfulDeliveryAPI/CDAArray.h>
#import <ContentfulDeliveryAPI/CDAAsset.h>
#import <ContentfulDeliveryAPI/CDAContentType.h>
#import <ContentfulDeliveryAPI/CDAField.h>
#import <ContentfulDeliveryAPI/CDALocalizablePersistedEntry.h>
#import <ContentfulDeliveryAPI/CDAPersistenceManager.h>
#import <ContentfulDeliveryAPI/CDASyncedSpace.h>

#import "CDAClient+Private.h"
#import "CDAContentTypeRegistry.h"
#import "CDAEntry+Private.h"
#import "CDAUtilities.h"

@interface CDAPersistenceManager () <CDASyncedSpaceDelegate>

@property (nonatomic) NSMutableDictionary* classesForLocalizedEntries;
@property (nonatomic) NSMutableDictionary* classesForEntries;
@property (nonatomic) CDAClient* client;
@property (nonatomic) BOOL hasChanged;
@property (nonatomic) NSMutableDictionary* mappingForEntries;
@property (nonatomic, copy) NSDictionary* query;
@property (nonatomic) CDASyncedSpace* syncedSpace;

@end

#pragma mark -

@implementation CDAPersistenceManager

+(void)seedFromBundleWithInitialCacheDirectory:(NSString*)initialCacheDirectory {
    NSString* cacheDirectory = CDACacheDirectory();
    
    if ([[NSFileManager defaultManager] contentsOfDirectoryAtPath:cacheDirectory error:nil].count > 0) {
        return;
    }
    
    NSArray* resources = [[NSBundle mainBundle] pathsForResourcesOfType:nil
                                                            inDirectory:initialCacheDirectory];
    
    for (NSString* resource in resources) {
        NSString* target = [cacheDirectory stringByAppendingPathComponent:resource.lastPathComponent];
        [[NSFileManager defaultManager] copyItemAtPath:resource toPath:target error:nil];
    }
}

#pragma mark -

-(Class)classForEntriesOfContentTypeWithIdentifier:(NSString *)identifier {
    return self.classesForEntries[identifier];
}

-(Class)classForLocalizedEntriesOfContentTypeWithIdentifier:(NSString *)identifier {
    return self.classesForLocalizedEntries[identifier];
}

-(id<CDALocalizedPersistedEntry>)createLocalizedPersistedEntryForContentTypeWithIdentifier:(NSString *)identifier {
    return [self.classesForLocalizedEntries[identifier] new];
}

-(id<CDAPersistedAsset>)createPersistedAsset {
    return [self.classForAssets new];
}

-(id<CDAPersistedEntry>)createPersistedEntryForContentTypeWithIdentifier:(NSString *)identifier {
    return [self.classesForEntries[identifier] new];
}

-(id<CDAPersistedSpace>)createPersistedSpace {
    return [self.classForSpaces new];
}

-(void)deleteAssetWithIdentifier:(NSString*)identifier {
    [self doesNotRecognizeSelector:_cmd];
}

-(void)deleteEntryWithIdentifier:(NSString*)identifier {
    [self doesNotRecognizeSelector:_cmd];
}

-(void)deleteLocalizedEntryWithIdentifier:(NSString*)identifier {
    [self doesNotRecognizeSelector:_cmd];
}

-(NSArray *)fetchAssetsFromDataStore {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(id<CDAPersistedAsset>)fetchAssetWithIdentifier:(NSString*)identifier {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(NSArray *)fetchEntriesFromDataStore {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(id<CDAPersistedEntry>)fetchEntryWithIdentifier:(NSString*)identifier {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(id<CDALocalizedPersistedEntry>)fetchLocalizedEntryWithIdentifier:(NSString*)identifier
                                                            locale:(NSString*)locale {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(id<CDAPersistedSpace>)fetchSpaceFromDataStore {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(void)handleAsset:(CDAAsset*)asset {
    id<CDAPersistedAsset> persistedAsset = [self fetchAssetWithIdentifier:asset.identifier];
    
    if (persistedAsset) {
        [self updatePersistedAsset:persistedAsset withAsset:asset];
    } else {
        [self persistedAssetForAsset:asset];
    }
}

-(void)handleEntry:(CDAEntry*)entry {
    id<CDAPersistedEntry> persistedEntry = [self fetchEntryWithIdentifier:entry.identifier];
    
    if (persistedEntry) {
        [self updatePersistedEntry:persistedEntry withEntry:entry];
    } else {
        [self persistedEntryForEntry:entry];
    }
}

-(void)handleResponseArray:(CDAArray*)array withSuccess:(void (^)())success {
    for (CDAEntry* entry in array.items) {
        [self handleEntry:entry];
        
        [entry resolveLinksWithIncludedAssets:nil
                                      entries:nil
                                   usingBlock:^CDAResource *(CDAResource *resource,
                                                             NSDictionary *assets,
                                                             NSDictionary *entries) {
                                       if (CDAClassIsOfType([resource class], CDAAsset.class)) {
                                           [self handleAsset:(CDAAsset*)resource];
                                       }
                                       
                                       if (CDAClassIsOfType([resource class], CDAEntry.class)) {
                                           [self handleEntry:(CDAEntry*)resource];
                                       }
                                       
                                       return resource;
                                   }];
    }
    
    [self saveDataStore];
    
    if (success) {
        success();
    }
}

-(NSArray *)identifiersOfHandledContentTypes {
    return self.classesForEntries.allKeys;
}

-(id)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(id)initWithClient:(CDAClient*)client {
    self = [super init];
    if (self) {
        self.classesForEntries = [@{} mutableCopy];
        self.classesForLocalizedEntries = [@{} mutableCopy];
        self.client = client;
        self.mappingForEntries = [@{} mutableCopy];
    }
    return self;
}

-(id)initWithClient:(CDAClient *)client query:(NSDictionary *)query {
    self = [super init];
    if (self) {
        self.classesForEntries = [@{} mutableCopy];
        self.classesForLocalizedEntries = [@{} mutableCopy];
        self.client = client;
        self.mappingForEntries = [@{} mutableCopy];
        self.query = query;
    }
    return self;
}

-(NSDictionary *)mappingForEntriesOfContentTypeWithIdentifier:(NSString *)identifier {
    NSDictionary* userDefinedMapping = self.mappingForEntries[identifier];

    if (!userDefinedMapping) {
        NSMutableArray* props = [[self propertiesForEntriesOfContentTypeWithIdentifier:identifier] mutableCopy];

        Protocol* proto = objc_getProtocol("CDAPersistedEntry");
        unsigned int definedPropsCount = 0;
        objc_property_t* definedProps = protocol_copyPropertyList(proto, &definedPropsCount);

        for (unsigned int i = 0; i < definedPropsCount; i++) {
            NSString* propName = [[NSString alloc] initWithCString:property_getName(definedProps[0]) encoding:NSUTF8StringEncoding];
            [props removeObject:propName];
        }

        NSMutableDictionary* automaticMapping = [@{} mutableCopy];

        CDAContentType* type = [self.client.contentTypeRegistry contentTypeForIdentifier:identifier];
        for (CDAField* field in type.fields) {
            if ([props containsObject:field.identifier]) {
                automaticMapping[[@"fields." stringByAppendingString:field.identifier]] = field.identifier;
            }
        }

        userDefinedMapping = [automaticMapping copy];
        [self setMapping:userDefinedMapping forEntriesOfContentTypeWithIdentifier:identifier];
    }
    
    return userDefinedMapping;
}

-(NSDictionary *)fieldMappingForEntriesOfContentTypeWithIdentifier:(NSString *)identifier {
    NSDictionary* mapping = [self mappingForEntriesOfContentTypeWithIdentifier:identifier];
    CDAContentType* type = [self.client.contentTypeRegistry contentTypeForIdentifier:identifier];

    NSMutableDictionary* fieldMapping = [mapping mutableCopy];
    for (NSString* key in mapping.allKeys) {
        if (![key hasPrefix:@"fields."]) {
            continue;
        }

        NSString* fieldId = [key componentsSeparatedByString:@"."][1];
        CDAField* field = [type fieldForIdentifier:fieldId];

        if (field && field.type == CDAFieldTypeArray && field.itemType != CDAFieldTypeSymbol) {
            [fieldMapping removeObjectForKey:key];
        }
    }

    return [fieldMapping copy];
}

-(NSDictionary *)relationshipMappingForEntriesOfContentTypeWithIdentifier:(NSString *)identifier {
    NSDictionary* fieldMapping = [self fieldMappingForEntriesOfContentTypeWithIdentifier:identifier];
    NSDictionary* mapping = [self mappingForEntriesOfContentTypeWithIdentifier:identifier];

    NSMutableDictionary* relationshipMapping = [mapping mutableCopy];
    for (NSString* key in fieldMapping.allKeys) {
        [relationshipMapping removeObjectForKey:key];
    }

    return [relationshipMapping copy];
}

-(void)performBlock:(void (^)())block {
    block();
}

-(void)performInitalSynchronizationForQueryWithSuccess:(void (^)())success
                                               failure:(CDARequestFailureBlock)failure {
    NSDate* syncTimestamp = [self roundedCurrentDate];
    
    [self.client fetchEntriesMatching:self.query success:^(CDAResponse *response, CDAArray *array) {
        [self performBlock:^{
            id<CDAPersistedSpace> space = [self fetchSpaceFromDataStore];
            space.lastSyncTimestamp = syncTimestamp;
        
            [self handleResponseArray:array withSuccess:success];
        }];
    } failure:failure];
}

-(void)performSubsequentSynchronizationWithSuccess:(void (^)())success
                                           failure:(CDARequestFailureBlock)failure {
    NSDate* syncTimestamp = [self roundedCurrentDate];
    NSMutableDictionary* query = [self.query mutableCopy];
    
    id<CDAPersistedSpace> space = [self fetchSpaceFromDataStore];
    if (space.lastSyncTimestamp) {
        query[@"sys.updatedAt[gt]"] = space.lastSyncTimestamp;
    }
    
    NSArray* knownAssetIds = [[self fetchAssetsFromDataStore] valueForKey:@"identifier"];
    NSDictionary* queryForAssets = @{ @"sys.id[in]": knownAssetIds,
                                      @"sys.updatedAt[gt]": space.lastSyncTimestamp };
    
    [self.client fetchEntriesMatching:query success:^(CDAResponse *response, CDAArray *entries) {
        [self performBlock:^{
            space.lastSyncTimestamp = syncTimestamp;
        }];
        
        [self.client fetchAssetsMatching:queryForAssets
                                 success:^(CDAResponse *response, CDAArray *assets) {
                                     [self performBlock:^{
                                         for (CDAAsset* asset in assets.items) {
                                             [self handleAsset:asset];
                                         }

                                         [self handleResponseArray:entries withSuccess:success];
                                     }];
                                 }
                                 failure:failure];
    } failure:failure];
}

-(void)performSynchronizationWithSuccess:(void (^)())success
                                 failure:(CDARequestFailureBlock)failure {
    NSAssert(self.classesForEntries.count > 0, @"At least one Entry class should be defined.");
    NSParameterAssert(self.classForAssets);
    NSParameterAssert(self.classForSpaces);
    NSParameterAssert(self.client);

    self.hasChanged = NO;

    if (self.query) {
        if (self.syncedSpace) {
            [self.syncedSpace performSynchronizationWithSuccess:^{
                [self performBlock:^{
                    [self performSubsequentSynchronizationWithSuccess:success failure:failure];
                }];
            } failure:failure];
        } else {
            [self.client initialSynchronizationMatching:@{ @"type": @"Deletion" } success:^(CDAResponse *response, CDASyncedSpace *space) {
                [self performBlock:^{
                    [self persistedSpaceForSpace:space];
                }];
                [self performInitalSynchronizationForQueryWithSuccess:success failure:failure];
            } failure:failure];
        }
        
        return;
    }
    
    if (!self.syncedSpace) {
        CDARequest* request = [self.client initialSynchronizationWithSuccess:^(CDAResponse *response,
                                                                               CDASyncedSpace *space) {
            [self performBlock:^{
                [self persistedSpaceForSpace:space];

                for (CDAAsset* asset in space.assets) {
                    [self persistedAssetForAsset:asset];
                }

                for (CDAEntry* entry in space.entries) {
                    [self persistedEntryForEntry:entry];
                }

                [self saveDataStore];

                if (success) {
                    success();
                }
            }];
        } failure:failure];

        if (request) {
            request = nil;
        }
        return;
    }
    
    [self.syncedSpace performSynchronizationWithSuccess:^{
        [self performBlock:^{
            id<CDAPersistedSpace> space = [self fetchSpaceFromDataStore];
            space.lastSyncTimestamp = self.syncedSpace.lastSyncTimestamp;
            space.syncToken = self.syncedSpace.syncToken;

            [self saveDataStore];

            if (success) {
                success();
            }
        }];
    } failure:failure];
}

-(id<CDAPersistedAsset>)persistedAssetForAsset:(CDAAsset*)asset {
    id<CDAPersistedAsset> persistedAsset = [self createPersistedAsset];
    [self updatePersistedAsset:persistedAsset withAsset:asset];
    return persistedAsset;
}

-(id<CDAPersistedEntry>)persistedEntryForEntry:(CDAEntry*)entry {
    NSString* identifier = entry.contentType.identifier;
    if (!identifier) {
        return nil;
    }

    id<CDAPersistedEntry> persistedEntry = [self createPersistedEntryForContentTypeWithIdentifier:identifier];
    if (!persistedEntry) {
        return nil;
    }

    [self updatePersistedEntry:persistedEntry withEntry:entry];
    return persistedEntry;
}

-(id<CDAPersistedSpace>)persistedSpaceForSpace:(CDASyncedSpace*)space {
    id<CDAPersistedSpace> persistedSpace = [self createPersistedSpace];
    persistedSpace.lastSyncTimestamp = space.lastSyncTimestamp;
    persistedSpace.syncToken = space.syncToken;
    return persistedSpace;
}

-(NSArray *)propertiesForEntriesOfContentTypeWithIdentifier:(NSString *)identifier {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(NSDate*)roundedCurrentDate {
    NSTimeInterval time = round([[NSDate date] timeIntervalSinceReferenceDate] / 60.0) * 60.0;
    return [NSDate dateWithTimeIntervalSinceReferenceDate:time];
}

-(void)saveDataStore {
    [self doesNotRecognizeSelector:_cmd];
}

-(void)setClass:(Class)classForEntries forEntriesOfContentTypeWithIdentifier:(NSString *)identifier {
    self.classesForEntries[identifier] = classForEntries;
}

-(void)setClass:(Class)classForEntries forLocalizedEntriesOfContentTypeWithIdentifier:(NSString *)identifier {
    self.classesForLocalizedEntries[identifier] = classForEntries;
}

-(void)setMapping:(NSDictionary *)mapping forEntriesOfContentTypeWithIdentifier:(NSString *)identifier {
    self.mappingForEntries[identifier] = mapping;
}

-(CDASyncedSpace *)syncedSpace {
    if (!_syncedSpace) {
        id<CDAPersistedSpace> persistedSpace = [self fetchSpaceFromDataStore];
        if (!persistedSpace) {
            return nil;
        }
        
        _syncedSpace = [CDASyncedSpace shallowSyncSpaceWithToken:persistedSpace.syncToken
                                                          client:self.client];
        _syncedSpace.delegate = self;
        _syncedSpace.lastSyncTimestamp = persistedSpace.lastSyncTimestamp;
    }
    
    return _syncedSpace;
}

-(void)updatePersistedAsset:(id<CDAPersistedAsset>)persistedAsset withAsset:(CDAAsset*)asset {
    persistedAsset.identifier = asset.identifier;
    persistedAsset.internetMediaType = asset.MIMEType;
    persistedAsset.url = asset.URL.absoluteString;

    if ([persistedAsset respondsToSelector:@selector(setWidth:)]) {
        persistedAsset.width = @(asset.size.width);
    }

    if ([persistedAsset respondsToSelector:@selector(setHeight:)]) {
        persistedAsset.height = @(asset.size.height);
    }
}

-(void)updatePersistedEntry:(id<CDAPersistedEntry>)persistedEntry withEntry:(CDAEntry*)entry {
    NSAssert([persistedEntry conformsToProtocol:@protocol(CDAPersistedEntry)],
             @"%@ does not conform to CDAPersistedEntry protocol.", persistedEntry);

    NSString* identifier = entry.contentType.identifier;
    if (!identifier) {
        return;
    }
    
    NSDictionary* mappingForEntries = [self mappingForEntriesOfContentTypeWithIdentifier:identifier];

    if (CDAClassIsOfType([persistedEntry class], CDALocalizablePersistedEntry.class)) {
        mappingForEntries = [self relationshipMappingForEntriesOfContentTypeWithIdentifier:identifier];
        CDALocalizablePersistedEntry* parent = (CDALocalizablePersistedEntry*)persistedEntry;
        NSDictionary* fieldMapping = [self fieldMappingForEntriesOfContentTypeWithIdentifier:identifier];
        NSString* initialLocale = entry.locale;

        for (NSString* locale in entry.localizedFields.allKeys) {
            id<CDALocalizedPersistedEntry> localEntry = [self fetchLocalizedEntryWithIdentifier:identifier
                                                                                         locale:locale];

            if (!localEntry) {
                localEntry = [self createLocalizedPersistedEntryForContentTypeWithIdentifier:identifier];
                [parent addLocalizedEntriesObject:localEntry];
            }

            entry.locale = locale;
            [entry mapFieldsToObject:localEntry usingMapping:fieldMapping];
            localEntry.identifier = entry.identifier;
            localEntry.locale = locale;
        }

        entry.locale = initialLocale;
    }

    [entry mapFieldsToObject:persistedEntry usingMapping:mappingForEntries];
    persistedEntry.identifier = entry.identifier;
}

#pragma mark - CDASyncedSpaceDelegate

-(void)syncedSpace:(CDASyncedSpace *)space didCreateAsset:(CDAAsset *)asset {
    [self syncedSpace:space didUpdateAsset:asset];
}

-(void)syncedSpace:(CDASyncedSpace *)space didCreateEntry:(CDAEntry *)entry {
    [self syncedSpace:space didUpdateEntry:entry];
}

-(void)syncedSpace:(CDASyncedSpace *)space didDeleteAsset:(CDAAsset *)asset {
    [self performBlock:^{
        self.hasChanged = YES;

        [self deleteAssetWithIdentifier:asset.identifier];
    }];
}

-(void)syncedSpace:(CDASyncedSpace *)space didDeleteEntry:(CDAEntry *)entry {
    [self performBlock:^{
        self.hasChanged = YES;

        [self deleteEntryWithIdentifier:entry.identifier];
    }];
}

-(void)syncedSpace:(CDASyncedSpace *)space didUpdateAsset:(CDAAsset *)asset {
    [self performBlock:^{
        self.hasChanged = YES;

        id<CDAPersistedAsset> persistedAsset = [self fetchAssetWithIdentifier:asset.identifier];

        if (!persistedAsset) {
            persistedAsset = [self createPersistedAsset];
        }

        [self updatePersistedAsset:persistedAsset withAsset:asset];
    }];
}

-(void)syncedSpace:(CDASyncedSpace *)space didUpdateEntry:(CDAEntry *)entry {
    [self performBlock:^{
        NSString* identifier = entry.contentType.identifier;
        if (!identifier) {
            return;
        }

        self.hasChanged = YES;

        id<CDAPersistedEntry> persistedEntry = [self fetchEntryWithIdentifier:entry.identifier];

        if (!persistedEntry) {
            persistedEntry = [self createPersistedEntryForContentTypeWithIdentifier:identifier];
        }

        if (persistedEntry) {
            [self updatePersistedEntry:persistedEntry withEntry:entry];
        }
    }];
}

@end
