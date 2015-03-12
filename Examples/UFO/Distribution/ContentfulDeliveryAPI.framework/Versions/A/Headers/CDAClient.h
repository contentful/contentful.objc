//
//  CDAClient.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

@import Foundation;

@class CDAArray;
@class CDAAsset;
@class CDAConfiguration;
@class CDAContentType;
@class CDAEntry;
@class CDAResponse;
@class CDARequest;
@class CDASpace;
@class CDASyncedSpace;

/** Possible Resource types. */
typedef NS_ENUM(NSInteger, CDAResourceType) {
    /** Asset */
    CDAResourceTypeAsset,
    /** Content Type */
    CDAResourceTypeContentType,
    /** Entry */
    CDAResourceTypeEntry,
};

typedef void(^CDAArrayFetchedBlock)(CDAResponse* response, CDAArray* array);
typedef void(^CDAAssetFetchedBlock)(CDAResponse* response, CDAAsset* asset);
typedef void(^CDAContentTypeFetchedBlock)(CDAResponse* response, CDAContentType* contentType);
typedef void(^CDAEntryFetchedBlock)(CDAResponse* response, CDAEntry* entry);
typedef void(^CDAObjectFetchedBlock)(CDAResponse* response, id responseObject);
typedef void(^CDARequestFailureBlock)(CDAResponse* response, NSError* error);
typedef void(^CDASpaceFetchedBlock)(CDAResponse* response, CDASpace* space);
typedef void(^CDASyncedSpaceFetchedBlock)(CDAResponse* response, CDASyncedSpace* space);

/**
 The CDAClient is used to request any information from the server. A client is associated with exactly
 one Space, but there is no limit to the concurrent number of clients existing at any one time.
 */
@interface CDAClient : NSObject

/** @name Creating a Client */

/**
*  Initializes a client for requesting data from the server.
*
*  @param spaceKey    The key of the Space containing the desired data.
*  @param accessToken The access token used for authentication against the API.
*
*  @return A client initialized for requesting data from the server.
*/
-(id)initWithSpaceKey:(NSString *)spaceKey accessToken:(NSString *)accessToken;

/**
 *  Initializes a client for requesting data from the server, while passing additional configuration
 *  options.
 *
 *  @param spaceKey      The key of the Space containing the desired data.
 *  @param accessToken   The access token used for authentication against the API.
 *  @param configuration Specific options for configuring the client.
 *
 *  @return A client initialized for requesting data from the server.
 */
-(id)initWithSpaceKey:(NSString *)spaceKey
          accessToken:(NSString *)accessToken
        configuration:(CDAConfiguration*)configuration;

/** @name Fetching Assets */

/**
 *  Fetch all Assets matching a query from the server.
 *
 *  @param query   The query which retrieved Assets shall match. Queries are expressed as dictionaries,
 *                 see [Search Parameters](https://www.contentful.com/developers/documentation/content-delivery-api/#search) for more information.
 *  @param success A block which gets called upon successful retrieval of all matching Assets.
 *  @param failure A block which gets called if an error occured during the retrieval process.
 *  @return The request used for fetching data.
 */
-(CDARequest*)fetchAssetsMatching:(NSDictionary*)query
                          success:(CDAArrayFetchedBlock)success
                          failure:(CDARequestFailureBlock)failure;

/**
 *  Fetch all Assets from the server.
 *
 *  @param success A block which gets called upon successful retrieval of all Assets.
 *  @param failure A block which gets called if an error occured during the retrieval process.
 *  @return The request used for fetching data.
 */
-(CDARequest*)fetchAssetsWithSuccess:(CDAArrayFetchedBlock)success
                             failure:(CDARequestFailureBlock)failure;

/**
 *  Fetch one specific Asset from the server.
 *
 *  @param identifier The identifier of the Asset to request.
 *  @param success    A block which gets called upon successful retrieval of the Asset.
 *  @param failure    A block which gets called if an error occured during the retrieval process.
 *  @return The request used for fetching data.
 */
-(CDARequest*)fetchAssetWithIdentifier:(NSString*)identifier
                               success:(CDAAssetFetchedBlock)success
                               failure:(CDARequestFailureBlock)failure;

/** @name Fetching Content Types */

/**
 *  Fetch all Content Types from the server.
 *
 *  @param success A block which gets called upon successful retrieval of all Content Types.
 *  @param failure A block which gets called if an error occured during the retrieval process.
 *  @return The request used for fetching data.
 */
-(CDARequest*)fetchContentTypesWithSuccess:(CDAArrayFetchedBlock)success
                                   failure:(CDARequestFailureBlock)failure;

/**
 *  Fetch one specific Content Type from the server.
 *
 *  @param identifier The identifier of the Content Type to request.
 *  @param success    A block which gets called upon successful retrieval of the Content Type.
 *  @param failure    A block which gets called if an error occured during the retrieval process.
 *  @return The request used for fetching data.
 */
-(CDARequest*)fetchContentTypeWithIdentifier:(NSString*)identifier
                                     success:(CDAContentTypeFetchedBlock)success
                                     failure:(CDARequestFailureBlock)failure;

/** @name Fetching Entries */

/**
 *  Fetch all Entries matching a query from the server.
 *
 *  @param query   The query which retrieved Entries shall match. Queries are expressed as dictionaries,
 *                 see [Search Parameters](https://www.contentful.com/developers/documentation/content-delivery-api/#search) for more information.
 *  @param success A block which gets called upon successful retrieval of all matching Entries.
 *  @param failure A block which gets called if an error occured during the retrieval process.
 *  @return The request used for fetching data.
 */
-(CDARequest*)fetchEntriesMatching:(NSDictionary*)query
                           success:(CDAArrayFetchedBlock)success
                           failure:(CDARequestFailureBlock)failure;

/**
 *  Fetch all Entries from the server.
 *
 *  @param success A block which gets called upon successful retrieval of all Entries.
 *  @param failure A block which gets called if an error occured during the retrieval process.
 *  @return The request used for fetching data.
 */
-(CDARequest*)fetchEntriesWithSuccess:(CDAArrayFetchedBlock)success
                              failure:(CDARequestFailureBlock)failure;

/**
 *  Fetch one specific Entry from the server.
 *
 *  @param identifier The identifier of the Entry to request.
 *  @param success    A block which gets called upon successful retrieval of the Entry.
 *  @param failure    A block which gets called if an error occured during the retrieval process.
 *  @return The request used for fetching data.
 */
-(CDARequest*)fetchEntryWithIdentifier:(NSString*)identifier
                               success:(CDAEntryFetchedBlock)success
                               failure:(CDARequestFailureBlock)failure;

/** @name Fetching Resources */

/**
 *  Fetch any kind of Resource from the server.
 *
 *  This method can be used in cases where the actual type of Resource to be fetched is determined at
 *  runtime.
 *
 *  @param resourceType The type of Resource to be fetched.
 *  @param query        The query which retrieved Entries shall match. Queries are expressed as
 *                      dictionaries, see [Search Parameters](https://www.contentful.com/developers/documentation/content-delivery-api/#search) for more information. If `nil`, any Resource matches.
 *  @param success      A block which gets called upon successful retrieval of all matching Resources.
 *  @param failure      A block which gets called if an error occured during the retrieval process.
 *
 *  @return The request used for fetching data.
 */
-(CDARequest*)fetchResourcesOfType:(CDAResourceType)resourceType
                          matching:(NSDictionary*)query
                           success:(CDAArrayFetchedBlock)success
                           failure:(CDARequestFailureBlock)failure;

/** @name Fetching Spaces */

/**
 *  Fetch the Space associated with this client.
 *
 *  @param success A block which gets called upon successful retrieval of the Space.
 *  @param failure A block which gets called if an error occured during the retrieval process.
 *  @return The request used for fetching data.
 */
-(CDARequest*)fetchSpaceWithSuccess:(CDASpaceFetchedBlock)success
                            failure:(CDARequestFailureBlock)failure;

/** @name Fetching Arrays */

/**
 *  Fetch all items from the given array.
 *
 *  For performance reasons, queries matching many items will return data in chunks. If you would
 *  still like to retrieve all available items from a given array, you can use this method.
 *
 *  @param array   The initially fetched array for which all items should now be fetched.
 *  @param success A block which gets called upon successful retrieval of the items.
 *  @param failure A block which gets called if an error occured during the retrieval process.
 */
-(void)fetchAllItemsFromArray:(CDAArray*)array
                      success:(void (^)(NSArray* items))success
                      failure:(CDARequestFailureBlock)failure;

/** @name Synchronization */

/**
 *  Perform the initial synchronization of a Space.
 *
 *  A `CDASyncedSpace` instance will be available once the initial synchronization is done.
 *  Subsequent updates can be done using that object.
 *
 *  Using this method, a complete synchronization of all
 *  [pages](https://www.contentful.com/developers/documentation/content-delivery-api/#sync-example-next-page)
 *  will be performed, which means that all data from the Space will be in memory.
 *
 *  @param success A block which gets called upon successful retrieval of all content.
 *  @param failure A block which gets called if an error occured during the retrieval process.
 *
 *  @return The request used for fetching data.
 */
-(CDARequest*)initialSynchronizationWithSuccess:(CDASyncedSpaceFetchedBlock)success
                                        failure:(CDARequestFailureBlock)failure;

/**
 *  Perform the initial synchronization of a Space.
 *
 *  A `CDASyncedSpace` instance will be available once the initial synchronization is done.
 *  Subsequent updates can be done using that object.
 *
 *  Using this method, a complete synchronization of all
 *  [pages](https://www.contentful.com/developers/documentation/content-delivery-api/#sync-example-next-page)
 *  will be performed, which means that all data from the Space will be in memory.
 *
 *  @param query   The query which retrieved Resources shall match. Queries are expressed as
 *                 dictionaries, see [Syncing Specific Content](https://www.contentful.com/developers/documentation/content-delivery-api/javascript/#sync-types) for more information. If `nil`, any Resource matches.
 *  @param success A block which gets called upon successful retrieval of all content.
 *  @param failure A block which gets called if an error occured during the retrieval process.
 *
 *  @return The request used for fetching data.
 */
-(CDARequest*)initialSynchronizationMatching:(NSDictionary*)query
                                     success:(CDASyncedSpaceFetchedBlock)success
                                     failure:(CDARequestFailureBlock)failure;

/** @name Register classes for custom value objects */

/**
 *  This method allows registering custom CDAEntry subclasses when Entries of a specific Content Type
 *  are retrieved from the server.
 *
 *  This allows the integration of custom value objects with convenience accessors, additional
 *  conversions or custom functionality so that you can easily build your data model upon Entries.
 *
 *  @param customClass The CDAEntry subclass which should be instantiated for Entries of the given
 *                     Content Type.
 *  @param contentType The Content Type for which custom value objects should be created.
 */
-(void)registerClass:(Class)customClass forContentType:(CDAContentType *)contentType;

/**
 *  This method allows registering custom CDAEntry subclasses when Entries of a specific Content Type
 *  are retrieved from the server. 
 *
 *  This allows the integration of custom value objects with convenience accessors, additional
 *  conversions or custom functionality so that you can easily build your data model upon Entries.
 *
 *  @param customClass The CDAEntry subclass which should be instantiated for Entries of the given
 *                     Content Type.
 *  @param identifier  The identifier of the Content Type for which custom value objects should be
 *                     created.
 */
-(void)registerClass:(Class)customClass forContentTypeWithIdentifier:(NSString*)identifier;

/**
 *  Resolve all Resources from the given array in case their data is not already available locally.
 *
 *  This is a convenience method for cases where an Entry links to a list of other Entries which were
 *  not included in the initial response, e.g. the list of tags associated with a blog post.
 *  However, it is also save to call this method on arrays of already fetched Resources or even
 *  any arrays which hold objects of any type. This means it is always safe to call this method even
 *  if you are unsure about the contents of an array at the point you are calling it.
 *
 *  @param array   The array of unfetched Resources, usually coming from an Entry's field value.
 *  @param success A block which gets called upon successful retrieval of all Resources.
 *  @param failure A block which gets called if an error occured during the retrieval process.
 */
-(void)resolveLinksFromArray:(NSArray*)array
                     success:(void (^)(NSArray* items))success
                     failure:(CDARequestFailureBlock)failure;

@end
