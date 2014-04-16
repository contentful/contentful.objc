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
 *  `deleteEntryWithIdentifier:`, `fetchAssetWithIdentifier:`, `fetchEntryWithIdentifier:`,
 *  `fetchSpaceFromDataStore` and `saveDataStore`.
 */
@interface CDAPersistenceManager : NSObject

/** @name Initializing a CDAPersistenceManager Object */

/**
*  Initializes a new `CDAPersistenceManager` object.
*
*  @param client The client used for performing synchronizations.
*
*  @return An initialized `CDAPersistenceManager` or `nil` if the object couldn't be created.
*/
-(id)initWithClient:(CDAClient*)client;

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
/** Class to be used for any persisted Entries. */
@property (nonatomic) Class classForEntries;

/** @name Mapping Fields to Properties */

/** 
 A mapping between the properties of persistent Resources and the Fields of Resources retrieved
 from Contentful.
 */
@property (nonatomic) NSDictionary* mappingForEntries;

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
 *  @return A new persisted Entry.
 */
-(id<CDAPersistedEntry>)createPersistedEntry;

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

@end
