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
-(void)syncedArray:(CDASyncedSpace*)space didCreateAsset:(CDAAsset*)asset;

/**
 *  This method is called once a new Entry is created.
 *
 *  @param space The relevant Space.
 *  @param entry The newly created Entry.
 */
-(void)syncedArray:(CDASyncedSpace*)space didCreateEntry:(CDAEntry*)entry;

/** @name Information on Deleted Resources */

/**
 *  This method is called once an existing Asset is deleted.
 *
 *  @param space The relevant Space.
 *  @param asset The deleted Asset.
 */
-(void)syncedArray:(CDASyncedSpace*)space didDeleteAsset:(CDAAsset*)asset;

/**
 *  This method is called once an existing Entry is deleted.
 *
 *  @param space The relevant Space.
 *  @param entry The deleted Entry.
 */
-(void)syncedArray:(CDASyncedSpace*)space didDeleteEntry:(CDAEntry*)entry;

/** @name Information on Updated Resources */

/**
 *  This method is called once an existing Asset is updated.
 *
 *  @param space The relevant Space.
 *  @param asset The updated Asset.
 */
-(void)syncedArray:(CDASyncedSpace*)space didUpdateAsset:(CDAAsset*)asset;

/**
 *  This method is called once an existing Entry is updated.
 *
 *  @param space The relevant Space.
 *  @param entry The updated Entry.
 */
-(void)syncedArray:(CDASyncedSpace*)space didUpdateEntry:(CDAEntry*)entry;

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
 *  @param success A block which is called upon the successful synchronization of the Space.
 *  @param failure A block which is called if any errors occur during the synchronization process.
 */
-(void)performSynchronizationWithSuccess:(void (^)())success failure:(CDARequestFailureBlock)failure;

@end
