//
//  CDAConfiguration.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

@import Foundation;

/**
 Class representing additional configuration options for a `CDAClient`.
 */
@interface CDAConfiguration : NSObject

/** @name Creating a configuration */

/**
 *  Creating a configuration with default parameters.
 *
 *  @return A configuration initialized with default parameters.
 */
+(instancetype)defaultConfiguration;

/** @name Configuring parameters */

/** Automatically retry requests if rate-limits are exceeded. */
@property (nonatomic) BOOL rateLimiting;

/** If `YES`, a secure HTTPS connection will be used instead of regular HTTP. Default value: `YES` */
@property (nonatomic) BOOL secure;

/** The server address to use for accessing any resources. Default value: "cdn.contentful.com" */
@property (nonatomic) NSString* server;

/** Configure a custom user-agent to be used in the HTTP request headers */
@property (nonatomic) NSString* userAgent;

/** @name Configure Preview Mode */

/** Preview mode allows retrieving unpublished Resources. 
 
 To use it, you have to obtain a special access
 token which you can get in the "API" tab of the Contentful app. 
 
 In preview mode, data can be invalid, because no validation is performed on unpublished entries. Your
 app needs to deal with that. Be aware that the access token is read-write and should in no case be
 shipped with a production app.
 
 Another difference in preview mode is that there are never any updates when performing 
 synchronizations. You will receive all Assets and Entries during the initial synchronization, just as
 in normal mode, including the unpublished Resources. Any subsequent synchronization will return 
 successful immediately, not reporting any changes. In addition to that, the parameters for syncing
 specific content will have no effect in preview mode, instead all content will always be fetched.
 
 In preview mode, the `include` parameter of a query is not used at all, instead includes will always
 be resolved for full ten levels. Because of this, preview mode will be slower than normal.
 */
@property (nonatomic) BOOL previewMode;

@end
