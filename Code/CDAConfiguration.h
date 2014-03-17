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

@end
