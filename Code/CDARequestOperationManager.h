//
//  CDARequestOperationManager.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 06/03/14.
//
//

#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import <ContentfulDeliveryAPI/CDAClient.h>

@class CDARequest;

@interface CDARequestOperationManager : AFHTTPRequestOperationManager

-(CDARequest*)fetchArrayAtURLPath:(NSString*)URLPath
                       parameters:(NSDictionary*)parameters
                          success:(CDAArrayFetchedBlock)success
                          failure:(CDARequestFailureBlock)failure;
-(CDAArray*)fetchArraySynchronouslyAtURLPath:(NSString*)URLPath
                                  parameters:(NSDictionary*)parameters
                                       error:(NSError **)error;
-(CDARequest*)fetchSpaceWithSuccess:(CDASpaceFetchedBlock)success
                            failure:(CDARequestFailureBlock)failure;
-(id)fetchURLPathSynchronously:(NSString*)URLPath
                    parameters:(NSDictionary*)parameters
                         error:(NSError **)error;
-(id)initWithSpaceKey:(NSString *)spaceKey
          accessToken:(NSString *)accessToken
               client:(CDAClient*)client
        configuration:(CDAConfiguration*)configuration;

@end
