//
//  CDAResource.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

@import Foundation;

@class CDAClient;
@class CDAResponse;

/** Base class of all remotely available entities. */
@interface CDAResource : NSObject <NSCoding, NSSecureCoding>

/** @name Accessing System Properties */

/** The `sys.id` of this Resource, used to uniquely identify it in its Space. */
@property (nonatomic, readonly) NSString* identifier;
/** Value of all system properties of this Resource. */
@property (nonatomic, readonly) NSDictionary* sys;

/** @name Comparing Resources */

/**
 *  Returns a Boolean value that indicates whether a given Resource is equal to the receiver.
 *
 *  @param resource The Resource with which to compare the receiver.
 *
 *  @return `YES` if `resource` is equivalent to the receiver, otherwise `NO`.
 */
-(BOOL)isEqualToResource:(CDAResource*)resource;

/** @name Persisting Resources */

/**
 *  Read a previously serialized Resource from file.
 *
 *  @param filePath The path to the file with a serialized Resource.
 *  @param client   The client to use for upcoming requests.
 *
 *  @return A new Resource initialized with values from a previously serialized Resource.
 */
+(instancetype)readFromFile:(NSString*)filePath client:(CDAClient*)client;

/**
 *  Serialize a Resource to a file.
 *
 *  This can be used for offline caching of Resources.
 *
 *  @param filePath The path to the file to which the Resource should be written.
 */
-(void)writeToFile:(NSString*)filePath;

/** @name Accessing Remote Data */

/** 
 Indicates whether or not the actual data of this Resource has been fetched yet. It will usually have
 the value `NO` for linked resources, unless you set `include` in the initial query. You can easily
 request the missing data by invoking `resolveWithSuccess:failure:` on it.
 */
@property (nonatomic, readonly) BOOL fetched;

/**
 *  Resolve a Link by fetching the actual data of the Resource. If the data of the Resource is already
 *  complete, the `success` block will be called immediately, with `response` being `nil` as no
 *  additional network requests were made.
 *
 *  @param success A block which gets called upon successful retrieval of all data.
 *  @param failure A block which gets called if an error occured during the retrieval process.
 */
-(void)resolveWithSuccess:(void (^)(CDAResponse* response, CDAResource* resource))success
                  failure:(void (^)(CDAResponse* response, NSError* error))failure;

@end
