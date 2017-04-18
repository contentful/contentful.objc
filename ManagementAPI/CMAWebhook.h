//
//  CMAWebhook.h
//  Pods
//
//  Created by Boris Bügling on 11/07/16.
//
//

#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>
#import "CMAResource.h"

NS_ASSUME_NONNULL_BEGIN

/** Definition of a webhook. */
@interface CMAWebhook : CDAResource <CMAResource>

/** Name of the given webhook. */
@property (nonatomic, copy) NSString* name;

/** URL that will be request when the webhook is triggered. */
@property (nonatomic, copy) NSURL* url;

/** List of event types which trigger the webhook. */
@property (nonatomic, copy) NSArray* topics;

/** Custom HTTP headers to be send with the webhook request. */
@property (nonatomic, copy) NSDictionary* headers;

/** HTTP basic auth username to be send with the webhook request. */
@property (nonatomic, copy) NSString* httpBasicUsername;

/** 
 HTTP basic auth password to be send with the webhook request.
 
 Note: The password cannot be retrieved via the API as it is stored in encrypted form.
 */
@property (nonatomic, copy) NSString* httpBasicPassword;

@end

NS_ASSUME_NONNULL_END
