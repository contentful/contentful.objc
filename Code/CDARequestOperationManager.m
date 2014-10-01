//
//  CDARequestOperationManager.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 06/03/14.
//
//

#if TARGET_OS_IPHONE
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#endif

@import ObjectiveC.runtime;

#import "CDAArray+Private.h"
#import "CDAClient+Private.h"
#import "CDAConfiguration.h"
#import "CDAError+Private.h"
#import "CDARequest+Private.h"
#import "CDARequestOperationManager.h"
#import "CDARequestSerializer.h"
#import "CDAResponse+Private.h"
#import "CDAResponseSerializer.h"
#import "CDASpace.h"

@interface CDARequestOperationManager ()

@property (nonatomic) NSDateFormatter* dateFormatter;

@end

#pragma mark -

@implementation CDARequestOperationManager

-(CDARequest*)buildRequestResultWithOperation:(AFHTTPRequestOperation*)operation {
    CDAClient* client = [(CDAResponseSerializer*)self.responseSerializer client];
    objc_setAssociatedObject(operation, "client", client, OBJC_ASSOCIATION_RETAIN);

    return [[CDARequest alloc] initWithRequestOperation:operation];
}

-(NSURLRequest*)buildRequestWithURLString:(NSString*)URLString parameters:(NSDictionary*)parameters {
    parameters = [self fixParametersInDictionary:parameters];
    return [[self.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil] copy];
}

-(CDARequest*)deleteURLPath:(NSString*)URLPath
                    headers:(NSDictionary*)headers
                 parameters:(NSDictionary*)parameters
                    success:(CDAObjectFetchedBlock)success
                    failure:(CDARequestFailureBlock)failure {
    return [self requestWithMethod:@"DELETE"
                           URLPath:URLPath
                           headers:headers
                        parameters:parameters
                           success:success
                           failure:failure];
}

-(CDARequest*)fetchArrayAtURLPath:(NSString*)URLPath
                       parameters:(NSDictionary*)parameters
                          success:(CDAArrayFetchedBlock)success
                          failure:(CDARequestFailureBlock)failure {
    return [self fetchURLPath:URLPath
                   parameters:parameters
                      success:^(CDAResponse *response, id responseObject) {
                          if (success) {
                              NSAssert([responseObject isKindOfClass:[CDAArray class]],
                                       @"Response object needs to be an array.");
                              [(CDAArray*)responseObject setQuery:parameters ?: @{}];
                              success(response, responseObject);
                          }
                      } failure:failure];
}

-(CDAArray*)fetchArraySynchronouslyAtURLPath:(NSString*)URLPath
                                  parameters:(NSDictionary*)parameters
                                       error:(NSError * __autoreleasing *)error {
    id responseObject = [self fetchURLPathSynchronously:URLPath parameters:parameters error:error];
    
    if (!responseObject) {
        return nil;
    }

    if ([responseObject isKindOfClass:[CDAError class]]) {
        NSAssert(false, [(CDAError*)responseObject message]);
        return nil;
    }
    
    NSAssert([responseObject isKindOfClass:[CDAArray class]], @"Response object needs to be an array.");
    return (CDAArray*)responseObject;
}

-(CDARequest*)fetchSpaceWithSuccess:(CDASpaceFetchedBlock)success
                            failure:(CDARequestFailureBlock)failure {
    return [self fetchURLPath:@""
                   parameters:nil
                      success:^(CDAResponse *response, id responseObject) {
                          NSAssert([responseObject isKindOfClass:[CDASpace class]],
                                   @"Response object needs to be a space.");
                          success(response, responseObject);
                      } failure:failure];
}

-(CDARequest*)fetchURLPath:(NSString*)URLPath
                parameters:(NSDictionary*)parameters
                   success:(CDAObjectFetchedBlock)success
                   failure:(CDARequestFailureBlock)failure {
    AFHTTPRequestOperation* operation = [self GET:URLPath parameters:parameters
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          if (!responseObject && operation.response.statusCode != 204) {
              if (failure) {
                  failure([CDAResponse responseWithHTTPURLResponse:operation.response], [NSError errorWithDomain:NSURLErrorDomain code:kCFURLErrorZeroByteResource userInfo:nil]);
              }
              
              return;
          }
          
          if (success) {
              success([CDAResponse responseWithHTTPURLResponse:operation.response], responseObject);
          }
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          if (failure) {
              if ([operation.responseObject isKindOfClass:[CDAError class]]) {
                  error = [operation.responseObject errorRepresentationWithCode:operation.response.statusCode];
              }
              
              failure([CDAResponse responseWithHTTPURLResponse:operation.response], error);
          }
      }];

    return [self buildRequestResultWithOperation:operation];
}

-(id)fetchURLPathSynchronously:(NSString*)URLPath
                    parameters:(NSDictionary*)parameters
                         error:(NSError * __autoreleasing *)error {
    NSURLRequest* request = [self buildRequestWithURLString:URLPath parameters:parameters];
    
    NSURLResponse* response;
    NSData* responseData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:error];
    if (!responseData) {
        return nil;
    }
    
    return [self.responseSerializer responseObjectForResponse:response
                                                         data:responseData
                                                        error:error];
}

-(NSDictionary*)fixParametersInDictionary:(NSDictionary*)parameters {
    NSMutableDictionary* mutableParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString* key, id value, BOOL *stop) {
        if ([value isKindOfClass:[NSArray class]]) {
            mutableParameters[key] = [value componentsJoinedByString:@","];
        }
        
        if ([value isKindOfClass:[NSDate class]]) {
            mutableParameters[key] = [self.dateFormatter stringFromDate:value];
        }
    }];
    
    return mutableParameters.count == 0 ? nil : [mutableParameters copy];
}

-(AFHTTPRequestOperation *)GET:(NSString *)URLString
                    parameters:(id)parameters
                       success:(void (^)(AFHTTPRequestOperation *, id))success
                       failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    parameters = [self fixParametersInDictionary:parameters];
    return [super GET:URLString parameters:parameters success:success failure:failure];
}

-(id)initWithSpaceKey:(NSString *)spaceKey
          accessToken:(NSString *)accessToken
               client:(CDAClient*)client
        configuration:(CDAConfiguration*)configuration {
    NSString* urlString = nil;
    if ([configuration.server rangeOfString:@"://"].location != NSNotFound) {
        urlString = configuration.server;
    } else {
        urlString = [NSString stringWithFormat:@"%@://%@", client.protocol, configuration.server];
    }

    if (spaceKey) {
        urlString = [urlString stringByAppendingFormat:@"/spaces/%@", spaceKey];
    }

    self = [super initWithBaseURL:[NSURL URLWithString:urlString]];
    if (self) {
        self.requestSerializer = [[CDARequestSerializer alloc] initWithAccessToken:accessToken];
        self.responseSerializer = [[CDAResponseSerializer alloc] initWithClient:client];

        if (configuration.userAgent) {
            [(CDARequestSerializer*)self.requestSerializer setUserAgent:configuration.userAgent];
        }
        
        self.dateFormatter = [NSDateFormatter new];
        NSLocale *posixLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [self.dateFormatter setLocale:posixLocale];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        
#if TARGET_OS_IPHONE
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
#endif
    }
    return self;
}

-(CDARequest *)postURLPath:(NSString *)URLPath
                   headers:(NSDictionary *)headers
                parameters:(NSDictionary *)parameters
                   success:(CDAObjectFetchedBlock)success
                   failure:(CDARequestFailureBlock)failure {
    return [self requestWithMethod:@"POST"
                           URLPath:URLPath
                           headers:headers
                        parameters:parameters
                           success:success
                           failure:failure];
}

-(CDARequest *)putURLPath:(NSString *)URLPath
                  headers:(NSDictionary *)headers
               parameters:(NSDictionary *)parameters
                  success:(CDAObjectFetchedBlock)success
                  failure:(CDARequestFailureBlock)failure {
    return [self requestWithMethod:@"PUT"
                           URLPath:URLPath
                           headers:headers
                        parameters:parameters
                           success:success
                           failure:failure];
}

-(CDARequest*)requestWithMethod:(NSString*)method
                        URLPath:(NSString*)URLPath
                 headers:(NSDictionary*)headers
              parameters:(NSDictionary*)parameters
                 success:(CDAObjectFetchedBlock)success
                 failure:(CDARequestFailureBlock)failure {
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:URLPath relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];

    [headers enumerateKeysAndObjectsUsingBlock:^(NSString* headerField, NSString* value, BOOL *stop) {
        [request setValue:value forHTTPHeaderField:headerField];
    }];

    [request setValue:CMAContentTypeHeader forHTTPHeaderField:@"Content-Type"];

    AFHTTPRequestOperation* operation = [self HTTPRequestOperationWithRequest:request
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          if (!responseObject && operation.response.statusCode != 204) {
              if (failure) {
                  failure([CDAResponse responseWithHTTPURLResponse:operation.response], [NSError errorWithDomain:NSURLErrorDomain code:kCFURLErrorZeroByteResource userInfo:nil]);
              }

              return;
          }

          if (success) {
              success([CDAResponse responseWithHTTPURLResponse:operation.response], responseObject);
          }
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          if (failure) {
              if ([operation.responseObject isKindOfClass:[CDAError class]]) {
                  error = [operation.responseObject errorRepresentationWithCode:operation.response.statusCode];
              }
              
              failure([CDAResponse responseWithHTTPURLResponse:operation.response], error);
          }
      }];
    [self.operationQueue addOperation:operation];

    return [self buildRequestResultWithOperation:operation];
}

@end
