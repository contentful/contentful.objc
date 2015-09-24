//
//  CoreDataManager.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 14/04/14.
//
//

@import CoreData;

#import <ContentfulDeliveryAPI/CDAPersistenceManager.h>

/**
 *  A specialization of `CDAPersistenceManager` which allows you to use Core Data.
 *
 *  This is a pretty basic implementation, mostly based on the Core Data example project by Apple.
 *  Depending on your use case, you might want to modify this class to your liking - that's why it is
 *  not a part of the Contentful SDK itself.
 *
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

/**
 *  Initialise a new instance of `CoreDataManager`.
 *
 *  @param client        The client to be used for fetching Resources from Contentful.
 *  @param dataModelName The name of your data model file (*.mom* or *.momd*).
 *  @param query         Entries matching that query will be fetched.
 *
 *  @return An initialised instance of `CoreDataManager` or `nil` if an error occured.
 */
-(id)initWithClient:(CDAClient *)client
      dataModelName:(NSString*)dataModelName
              query:(NSDictionary *)query;

/** @name Fetching Resources */

/**
 *  Fetch Entries matching a predicate.
 *
 *  @param identifier   Identifier of the Content Type all Entries conform to.
 *  @param predicate    A string which will be converted to a `NSPredicate`.
 *
 *  @return An array of all Entries matching the given predicate.
 */
-(NSArray*)fetchEntriesOfContentTypeWithIdentifier:(NSString*)identifier
                                 matchingPredicate:(NSString*)predicate;

/**
 *  Fetch request for all Entries matching a predicate.
 *
 *  @param identifier   Identifier of the Content Type all Entries conform to.
 *  @param predicate A string which will be converted to a `NSPredicate`.
 *
 *  @return A fetch request for all Entries matching the given predicate.
 */
-(NSFetchRequest*)fetchRequestForEntriesOfContentTypeWithIdentifier:(NSString*)identifier
                                                  matchingPredicate:(NSString*)predicate;

/** @name Managed Object Context */

/** The default managed object context of the receiver. */
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

/** @name Testing Support */

/** 
 URL of the underlying store file.
 
 Only needed for unit testing.
 */
@property (nonatomic, readonly) NSURL* storeURL;

/** Delete all managed objects from the persistent store. */
-(void)deleteAll;

@end
