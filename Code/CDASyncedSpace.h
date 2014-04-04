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
@interface CDASyncedSpace : NSObject

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

/**
 Retrieve the synchronization token for the next synchronization operation.
 
 This token will change after each successful `performSynchronizationWithSuccess:failure:` call.
 You can use this token to reinstantiate a synchronization session after an app relaunch, using
 `shallowSyncSpaceWithToken:`. Be aware that using an older token to reinstate a session might yield
 unexpected results, so make sure you keep any tokens you store yourself up-to-date.
 */
@property (nonatomic, readonly) NSString* syncToken;

/** @name Reinstantiate Synchronization Sessions */

/**
 *  Initializes a shallow synchronization space using the given synchronization token.
 *
 *  A shallow `CDASyncSpace` will not return any Resources from the `assets` or `entries` properties,
 *  so the main use case is receiving updates via the `delegate`. In contrast to regular synchronization
 *  spaces, a shallow one will also only return shallow Assets from the `syncedSpace:didDeleteAsset:`
 *  and shallow Entries from `syncedSpace:didDeleteEntry:`. Shallow resources will only have a value
 *  for the `identifier` property and no Field values.
 *
 *  @param syncToken The synchronization token, retrieve earlier from the `syncToken` property.
 *  @param client    The client instance used for fetching Resources. It needs to be associated to the
 *                   same Space as your original synchronization session.
 *
 *  @return A synchronization space initialized for continuing the session.
 */
+(instancetype)shallowSyncSpaceWithToken:(NSString*)syncToken client:(CDAClient*)client;

@end
