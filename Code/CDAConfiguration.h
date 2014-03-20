//
//  CDAConfiguration.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import <Foundation/Foundation.h>

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

/** If `YES`, a secure HTTPS connection will be used instead of regular HTTP. Default value: `YES` */
@property (nonatomic) BOOL secure;
/** The server address to use for accessing any resources. Default value: "http://cdn.contentful.com" */
@property (nonatomic) NSString* server;

/** @name Configure Preview Mode */

/** Preview mode allows retrieving unpublished Resources. To use it, you have to obtain a special access
 token from [here](https://www.contentful.com/developers/documentation/content-management-api/#getting-started). */
@property (nonatomic) BOOL previewMode;

/** In preview mode, the default locale of the Space is not used. If there is more than one locale in
 the Space you are using, this property needs to be set or an exception will be thrown at runtime. */
@property (nonatomic) NSString* previewLocale;

@end
