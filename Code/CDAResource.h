//
//  CDAResource.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import <Foundation/Foundation.h>

@class CDAResponse;

/** Base class of all remotely available entities. */
@interface CDAResource : NSObject

/** @name Accessing System Properties */

/** The `sys.id` of this Resource, used to uniquely identify it in its Space. */
@property (nonatomic, readonly) NSString* identifier;
/** Value of all system properties of this Resource. */
@property (nonatomic, readonly) NSDictionary* sys;

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
