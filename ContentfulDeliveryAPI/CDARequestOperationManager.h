//
//  CDARequestOperationManager.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 06/03/14.
//
//

#import <AFNetworking/AFHTTPSessionManager.h>
#import "CDAClient.h"

@class CDARequest;

@interface CDARequestOperationManager : AFHTTPSessionManager

-(instancetype)initWithSpaceKey:(NSString *)spaceKey
                    accessToken:(NSString *)accessToken
                         client:(CDAClient*)client
                  configuration:(CDAConfiguration*)configuration
                   isCMARequest:(BOOL)isCMARequest;

-(CDARequest*)deleteURLPath:(NSString*)URLPath
                    headers:(NSDictionary*)headers
                 parameters:(NSDictionary*)parameters
                    success:(CDAObjectFetchedBlock)success
                    failure:(CDARequestFailureBlock)failure;
-(CDARequest*)fetchArrayAtURLPath:(NSString*)URLPath
                       parameters:(NSDictionary*)parameters
                          success:(CDAArrayFetchedBlock)success
                          failure:(CDARequestFailureBlock)failure;
-(CDAArray*)fetchArraySynchronouslyAtURLPath:(NSString*)URLPath
                                  parameters:(NSDictionary*)parameters
                                       error:(NSError **)error;
-(CDARequest*)fetchSpaceWithSuccess:(CDASpaceFetchedBlock)success
                            failure:(CDARequestFailureBlock)failure;
-(CDARequest*)fetchURLPath:(NSString*)URLPath
                parameters:(NSDictionary*)parameters
                   success:(CDAObjectFetchedBlock)success
                   failure:(CDARequestFailureBlock)failure;

-(CDARequest*)postURLPath:(NSString*)URLPath
                  headers:(NSDictionary*)headers
               parameters:(NSDictionary*)parameters
                  success:(CDAObjectFetchedBlock)success
                  failure:(CDARequestFailureBlock)failure;
-(CDARequest*)putURLPath:(NSString*)URLPath
                 headers:(NSDictionary*)headers
              parameters:(NSDictionary*)parameters
                 success:(CDAObjectFetchedBlock)success
                 failure:(CDARequestFailureBlock)failure;

+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request
                 returningResponse:(__autoreleasing NSURLResponse **)responsePtr
                             error:(__autoreleasing NSError **)errorPtr;

@end
