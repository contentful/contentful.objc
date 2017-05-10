//
//  CDAResource+Management.h
//  Pods
//
//  Created by Boris Bügling on 30/07/14.
//
//

#import "CDAResource.h"
#import "CDARequest.h"
#import "CDAClient.h"

@interface CDAResource (Management)

@property (nonatomic, readonly) NSDictionary* linkDictionary;
@property (nonatomic, readonly) NSString* URLPath;

-(CDARequest*)performDeleteToFragment:(NSString*)fragment
                          withSuccess:(void (^)())success
                              failure:(CDARequestFailureBlock)failure;

-(CDARequest*)performPutToFragment:(NSString*)fragment
                    withParameters:(NSDictionary*)parameters
                           success:(void (^)())success
                           failure:(CDARequestFailureBlock)failure;

-(CDARequest*)performPutToFragment:(NSString*)fragment
                       withSuccess:(void (^)())success
                           failure:(CDARequestFailureBlock)failure;

@end
