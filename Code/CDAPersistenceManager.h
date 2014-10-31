//
//  CDAPersistenceManager.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 15/04/14.
//
//

#import <ContentfulDeliveryAPI/CDAClient.h>
#import <ContentfulDeliveryAPI/CDAPersistedAsset.h>
#import <ContentfulDeliveryAPI/CDAPersistedEntry.h>
#import <ContentfulDeliveryAPI/CDAPersistedSpace.h>

/**
 *  Subclasses of this class manage a persistent store.
 *
 *  A minimal subclass needs to at least override `deleteAssetWithIdentifier:`,
 *  `deleteEntryWithIdentifier:`, `fetchAssetsFromDataStore`, `fetchAssetWithIdentifier:`,
 *  `fetchEntryWithIdentifier:`, `fetchSpaceFromDataStore` and `saveDataStore`.
 */
@interface CDAPersistenceManager : NSObject

/** @name Initializing a CDAPersistenceManager Object */

/**
*  Initializes a new `CDAPersistenceManager` object. Using this initializer will use synchronization
*  for retrieving Resources.
*
*  @param client The client used for performing synchronizations.
*
*  @return An initialized `CDAPersistenceManager` or `nil` if the object couldn't be created.
*/
-(id)initWithClient:(CDAClient*)client;

/**
 *  Initializes a new `CDAPersistenceManager` object. Using this initializer will use queries for
 *  retrieving Resources.
 *
 *  @param client   The client used for performing queries.
 *  @param query    The query to be performed.
 *
 *  @return An initialized `CDAPersistenceManager` or `nil` if the object couldn't be created.
 */
-(id)initWithClient:(CDAClient *)client query:(NSDictionary*)query;

/** @name Performing Synchronizations */

/**
 *  Perform an initial or subsequent synchronization of all Space content to the persistent store.
 *
 *  @param success Completion handler called when the synchronization finished successfully.
 *  @param failure Error handler called when any problem occured during the synchronization.
 */
-(void)performSynchronizationWithSuccess:(void (^)())success
                                 failure:(CDARequestFailureBlock)failure;

/** @name Defining Classes for Persistent Resources */

/** Class to be used for any persisted Assets. */
@property (nonatomic) Class classForAssets;
/** Class to be used for any persisted Spaces. */
@property (nonatomic) Class classForSpaces;

/**
 *  Class used for persisted Entries of a certain Content Type.
 *
 *  @param identifier Identifier of the Content Type.
 *
 *  @return Class to be used for Entries of that Content Type.
 */
-(Class)classForEntriesOfContentTypeWithIdentifier:(NSString*)identifier;

/** List of identifiers of all Content Types for which a class was defined. */
@property (nonatomic, readonly) NSArray* identifiersOfHandledContentTypes;

/**
 *  Class to be used for persisted Entries of a certain Content Type. Entries for which no class was
 *  defined will not be persisted to the data store.
 *
 *  @param classForEntries Class to be used for Entries of the given Content Type.
 *  @param identifier      Identifier of the Content Type.
 */
-(void)setClass:(Class)classForEntries forEntriesOfContentTypeWithIdentifier:(NSString*)identifier;

/** @name Mapping Fields to Properties */

/**
 Get the mapping between the properties of persistent Resources and the Fields of Resources
 retrieved from Contentful.
 
 Note: If the property names on persisted Entries match the field identifiers on Contentful, the 
 mapping can be provided automatically and you do not need to call this method.
 
 @param identifier Identifier of the Content Type in question.
 @return The defined mapping for Fields of Entries of the given Content Type.
 */
-(NSDictionary*)mappingForEntriesOfContentTypeWithIdentifier:(NSString*)identifier;

/**
 Get all defined properties of the persited Entry class of a certain Content Type.

 @param identifier      Identifier of the Content Type.
 @return List of properties which are defined on the relevant persisted Entry class.
 */
-(NSArray*)propertiesForEntriesOfContentTypeWithIdentifier:(NSString*)identifier;

/**
 *  Set the mapping between the properties of persistent Resources and the Fields of Resources
 *  retrieved from Contentful.
 *
 *  @param mapping    The mapping for Fields of Entries of the given Content Type.
 *  @param identifier Identifier of the Content Type in question.
 */
-(void)setMapping:(NSDictionary*)mapping forEntriesOfContentTypeWithIdentifier:(NSString*)identifier;

/** @name Interact with the Data Store. */

/**
 *  Override this method in subclasses if Asset instances cannot be created with +new.
 *
 *  @return A new persisted Asset.
 */
-(id<CDAPersistedAsset>)createPersistedAsset;

/**
 *  Override this method in subclasses if Entry instances cannot be created with +new.
 *
 *  @param identifier Identifier of the Content Type of the new Entry.
 *  @return A new persisted Entry.
 */
-(id<CDAPersistedEntry>)createPersistedEntryForContentTypeWithIdentifier:(NSString*)identifier;

/**
 *  Override this method in subclasses if Space instances cannot be created with +new.
 *
 *  @return A new persisted Space.
 */
-(id<CDAPersistedSpace>)createPersistedSpace;

/**
 *  Delete an Asset from the persisten store.
 *
 *  This method needs to be overridden by subclasses.
 *
 *  @param identifier The identifier of the Asset to delete.
 */
-(void)deleteAssetWithIdentifier:(NSString*)identifier;

/**
 *  Delete an Entry from the persisten store.
 *
 *  This method needs to be overridden by subclasses.
 *
 *  @param identifier The identifier of the Entry to delete.
 */
-(void)deleteEntryWithIdentifier:(NSString*)identifier;

/**
 *  Fetch all Assets from the store.
 *
 *  @return An array of all Assets.
 */
-(NSArray*)fetchAssetsFromDataStore;

/**
 *  Retrieve an Asset from the persistent store.
 *
 *  This method needs to be overridden by subclasses.
 *
 *  @param identifier The identifier of the Asset to fetch.
 *
 *  @return The Asset with the given identifier or `nil` if it could not be found.
 */
-(id<CDAPersistedAsset>)fetchAssetWithIdentifier:(NSString*)identifier;

/**
 *  Retrieve an Entry from the persistent store.
 *
 *  This method needs to be overridden by subclasses.
 *
 *  @param identifier The identifier of the Entry to fetch.
 *
 *  @return The Entry with the given identifier or `nil` if it could not be found.
 */
-(id<CDAPersistedEntry>)fetchEntryWithIdentifier:(NSString*)identifier;

/**
 *  Fetch a Space from the persistent store.
 *
 *  This method needs to be overridden by subclasses.
 *
 *  @return The fetched Space or `nil` if none could be retrieved.
 */
-(id<CDAPersistedSpace>)fetchSpaceFromDataStore;

/**
 *  Save all changes of the object model to the persistent store.
 *
 *  This method needs to be overridden by subclasses.
 *
 */
-(void)saveDataStore;

/**
 *  This method will be called internally each time new values for an Entry are available, including
 *  during its initial creation. You can override it in your subclass to implement any custom behaviour,
 *  for example resolving relationships between Resources. Usually, you want to call super in the
 *  process to get updates for primitive values for free.
 *
 *  @param persistedEntry The persisted Entry to be updated by this method.
 *  @param entry          The Entry which contains the values used for the update operation.
 */
-(void)updatePersistedEntry:(id<CDAPersistedEntry>)persistedEntry withEntry:(CDAEntry*)entry;

/** @name Interact with Contentful */

/** The client object used for all API requests to Contentful. */
@property (nonatomic, readonly) CDAClient* client;

/** @name Use Initial Seed Data */

/**
 *  Copy seed data from main bundle to the appropriate places.
 *
 *  @param initialCacheDirectory Directory in the main bundle which contains cached Resources.
 */
+(void)seedFromBundleWithInitialCacheDirectory:(NSString*)initialCacheDirectory;

@end
