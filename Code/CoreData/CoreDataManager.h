//
//  CoreDataManager.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 14/04/14.
//
//

#import <ContentfulDeliveryAPI/CDAPersistenceManager.h>

/**
 *  A specialization of `CDAPersistenceManager` which allows you to use Core Data.
 */
@interface CoreDataManager : CDAPersistenceManager

/** @name Initialising the CoreDataManager Object */

/**
*  Initialise a new instance of `CoreDataManager`.
*
*  @param client        The client to be used for fetching Resources from Contentful.
*  @param dataModelName The name of your data model file (*.mom* or *.momd*).
*
*  @return An initialised instance of `CoreDataManager` or `nil` if an error occured.
*/
-(id)initWithClient:(CDAClient *)client dataModelName:(NSString*)dataModelName;

/** @name Fetching Resources */

/**
*  Fetch all Assets from the store.
*
*  @return An array of all Assets.
*/
-(NSArray*)fetchAssetsFromDataStore;

/**
 *  Fetch all Entries from the store.
 *
 *  @return An array of all Entries.
 */
-(NSArray*)fetchEntriesFromDataStore;

/**
 *  Fetch Entries matching a predicate.
 *
 *  @param predicate A string which will be converted to a `NSPredicate`.
 *
 *  @return An array of all Entries matching the given predicate.
 */
-(NSArray*)fetchEntriesMatchingPredicate:(NSString*)predicate;

/** @name Testing Support */

/** 
 URL of the underlying store file.
 
 Only needed for unit testing.
 */
@property (nonatomic, readonly) NSURL* storeURL;

@end
