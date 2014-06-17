//
//  CDASyncedSpace.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 25/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAClient.h>

@class CDAAsset;
@class CDAEntry;
@class CDASyncedSpace;

/**
 The delegate of a `CDASyncedSpace` object must adopt the `CDASyncedSpaceDelegate`
 protocol. The optional methods will inform the delegate about updates on the contents of the target
 `CDASyncedSpace`.
 */
@protocol CDASyncedSpaceDelegate <NSObject>

@optional

/** @name Information on Created Resources */

/**
 *  This method is called once a new Asset is created.
 *
 *  @param space The relevant Space.
 *  @param asset The newly created Asset.
 */
-(void)syncedSpace:(CDASyncedSpace*)space didCreateAsset:(CDAAsset*)asset;

/**
 *  This method is called once a new Entry is created.
 *
 *  @param space The relevant Space.
 *  @param entry The newly created Entry.
 */
-(void)syncedSpace:(CDASyncedSpace*)space didCreateEntry:(CDAEntry*)entry;

/** @name Information on Deleted Resources */

/**
 *  This method is called once an existing Asset is deleted.
 *
 *  @param space The relevant Space.
 *  @param asset The deleted Asset.
 */
-(void)syncedSpace:(CDASyncedSpace*)space didDeleteAsset:(CDAAsset*)asset;

/**
 *  This method is called once an existing Entry is deleted.
 *
 *  @param space The relevant Space.
 *  @param entry The deleted Entry.
 */
-(void)syncedSpace:(CDASyncedSpace*)space didDeleteEntry:(CDAEntry*)entry;

/** @name Information on Updated Resources */

/**
 *  This method is called once an existing Asset is updated.
 *
 *  @param space The relevant Space.
 *  @param asset The updated Asset.
 */
-(void)syncedSpace:(CDASyncedSpace*)space didUpdateAsset:(CDAAsset*)asset;

/**
 *  This method is called once an existing Entry is updated.
 *
 *  @param space The relevant Space.
 *  @param entry The updated Entry.
 */
-(void)syncedSpace:(CDASyncedSpace*)space didUpdateEntry:(CDAEntry*)entry;

@end

#pragma mark -

/**
 *  A `CDASyncedSpace` represents the complete contents of a Space. It can be synchronized via 
 *  delta updates at any time.
 */
@interface CDASyncedSpace : NSObject <NSCoding, NSSecureCoding>

/** @name Accessing Space Contents */

/** All published Assets in the given Space. */
@property (nonatomic, readonly) NSArray* assets;
/** All published Entries in the given Space. */
@property (nonatomic, readonly) NSArray* entries;

/** @name Managing the Delegate */

/** The object acts as a delegate on the receiving synchronized Space. */
@property (nonatomic) id<CDASyncedSpaceDelegate> delegate;

/** @name Perform Synchronizations */

/**
 *  Perform a synchronization of the receiving synchronized Space.
 *
 *  Using this method, a complete synchronization of all 
 *  [pages](https://www.contentful.com/developers/documentation/content-delivery-api/#sync-example-next-page) 
 *  will be performed, which means that all data from the Space will be in memory.
 *
 *  @param success A block which is called upon the successful synchronization of the Space.
 *  @param failure A block which is called if any errors occur during the synchronization process.
 */
-(void)performSynchronizationWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure;

/** @name Persisting Synchronized Spaces */

/**
 *  Read a previously serialized synchronized Space from file.
 *
 *  @param filePath The path to the file with a serialized synchronized Space.
 *  @param client   The client to use for upcoming requests.
 *
 *  @return A new Resource initialized with values from a previously serialized synchronized Space.
 */
+(instancetype)readFromFile:(NSString*)filePath client:(CDAClient*)client;

/**
 *  Serialize a synchronized Space to a file.
 *
 *  This can be used for offline caching of synchronized Spaces.
 *
 *  @param filePath The path to the file to which the synchronized Space should be written.
 */
-(void)writeToFile:(NSString*)filePath;

/** @name Reinstantiate Synchronization Sessions */

/**
 *  Initializes a shallow synchronized Space using the given synchronization token.
 *
 *  A shallow `CDASyncSpace` will not return any Resources from the `assets` or `entries` properties,
 *  so the main use case is receiving updates via the `delegate`. In contrast to regular synchronized
 *  Spaces, a shallow one will also only return shallow Assets from the `syncedSpace:didDeleteAsset:`
 *  and shallow Entries from `syncedSpace:didDeleteEntry:`. Shallow resources will only have a value
 *  for the `identifier` property and no Field values. Also be aware of the fact that a shallow
 *  synchronized Space will report resources which were unpublished and later published again as an
 *  update, not a create via the delegate, use your own local state to decide if an update you
 *  receive is actually a create.
 *
 *  @param syncToken The synchronization token, retrieve earlier from the `syncToken` property.
 *  @param client    The client instance used for fetching Resources. It needs to be associated to the
 *                   same Space as your original synchronization session.
 *
 *  @return A synchronized Space initialized for continuing the session.
 */
+(instancetype)shallowSyncSpaceWithToken:(NSString*)syncToken client:(CDAClient*)client;

/**
 *  Timestamp of the last synchronization operation. 
 *
 *  Store this alongside the `syncToken` and restore it on a newly created synchronized Space to
 *  ensure that the `delegate` will be correctly informed about updates. If you fail to restore it,
 *  only create and delete operations will be reported to the delegate of a shallow synchronized Space.
 *
 */
@property (nonatomic) NSDate* lastSyncTimestamp;

/**
 Retrieve the synchronization token for the next synchronization operation.
 
 This token will change after each successful `performSynchronizationWithSuccess:failure:` call.
 You can use this token to reinstantiate a synchronization session after an app relaunch, using
 `shallowSyncSpaceWithToken:`. Be aware that using an older token to reinstate a session might yield
 unexpected results, so make sure you keep any tokens you store yourself up-to-date.
 */
@property (nonatomic, readonly) NSString* syncToken;

@end
