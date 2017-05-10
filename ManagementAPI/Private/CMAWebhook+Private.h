//
//  CMAWebhook.h
//  Pods
//
//  Created by Boris Bügling on 17/11/14.
//
//

#import "CMAWebhook.h"

@interface CMAWebhook (Private)

+(NSDictionary*)parametersForWebhookWithName:(NSString*)name
                                         url:(NSURL*)url
                                      topics:(NSArray*)topics
                                     headers:(NSDictionary*)headers
                           httpBasicUsername:(NSString*)httpBasicUsername
                           httpBasicPassword:(NSString*)httpBasicPassword;

@end
