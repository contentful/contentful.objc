//
//  CDARequestOperationManager.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 06/03/14.
//
//

@import Darwin.TargetConditionals;

#if TARGET_OS_IPHONE
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#endif

#import <ContentfulDeliveryAPI/CDAConfiguration.h>
#import <ContentfulDeliveryAPI/CDASpace.h>

#import "CDAArray+Private.h"
#import "CDAClient+Private.h"
#import "CDAError+Private.h"
#import "CDARequest+Private.h"
#import "CDARequestOperationManager.h"
#import "CDARequestSerializer.h"
#import "CDAResponse+Private.h"
#import "CDAResponseSerializer.h"
#import "CDAUtilities.h"

@interface CDARequestOperationManager ()

@property (nonatomic) NSDateFormatter* dateFormatter;
@property (nonatomic) BOOL rateLimiting;

@end

#pragma mark -

@implementation CDARequestOperationManager

-(NSURLRequest*)buildRequestWithURLString:(NSString*)URLString parameters:(NSDictionary*)parameters {
    parameters = [self fixParametersInDictionary:parameters];

    URLString = [[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString];
    NSParameterAssert(URLString);

    return [[self.requestSerializer requestWithMethod:@"GET" URLString:URLString parameters:parameters error:nil] copy];
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
                              if (!CDAClassIsOfType([responseObject class], CDAArray.class)) {
                                  if (CDAClassIsOfType([responseObject class], CDAError.class)) {

                                      NSError *errorResponse = [((CDAError *)responseObject) errorRepresentationWithCode:response.statusCode];
                                      failure(response, errorResponse);
                                    return;
                                  }
                                  NSAssert(CDAClassIsOfType([responseObject class], CDAArray.class),
                                           @"Response object needs to be a CDAArray or a CDAError.");
                                  return;
                              }
                              // Success
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

    if (CDAClassIsOfType([responseObject class], CDAError.class)) {
        NSAssert(false, [(CDAError*)responseObject message]);
        return nil;
    }
    
    NSAssert(CDAClassIsOfType([responseObject class], CDAArray.class),
             @"Response object needs to be an array.");
    return (CDAArray*)responseObject;
}

-(CDARequest*)fetchSpaceWithSuccess:(CDASpaceFetchedBlock)success
                            failure:(CDARequestFailureBlock)failure {
    return [self fetchURLPath:@""
                   parameters:nil
                      success:^(CDAResponse *response, id responseObject) {
                          if (CDAClassIsOfType([responseObject class], CDAError.class)) {
                              CDAError* error = (CDAError*)responseObject;
                              failure(response, [error errorRepresentationWithCode:response.statusCode]);
                              return;
                          }

                          NSAssert(CDAClassIsOfType([responseObject class], CDASpace.class),
                                   @"Response object needs to be a space.");
                          success(response, responseObject);
                      } failure:failure];
}

-(CDARequest*)fetchURLPath:(NSString*)URLPath
                parameters:(NSDictionary*)parameters
                   success:(CDAObjectFetchedBlock)success
                   failure:(CDARequestFailureBlock)failure {
    parameters = [self fixParametersInDictionary:parameters];
    return [self requestWithMethod:@"GET" URLPath:URLPath headers:nil parameters:parameters
                           success:success failure:failure];

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
        self.rateLimiting = configuration.rateLimiting;

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
    NSString* URLString = [[NSURL URLWithString:URLPath relativeToURL:self.baseURL] absoluteString];
    NSParameterAssert(URLString);
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:URLString parameters:parameters error:nil];

    [headers enumerateKeysAndObjectsUsingBlock:^(NSString* headerField, NSString* value, BOOL *stop) {
        [request setValue:value forHTTPHeaderField:headerField];
    }];

    [request setValue:CMAContentTypeHeader forHTTPHeaderField:@"Content-Type"];

    NSURLSessionTask* task = [self sessionTaskWithRequest:request
                                               retryCount:0
                                                  success:success
                                                  failure:failure];

    CDARequest *cdaRequest = [[CDARequest alloc] initWithSessionTask:task];
    return cdaRequest;
}

-(NSURLSessionTask*)sessionTaskWithRequest:(NSURLRequest*)request
                                retryCount:(NSUInteger)retryCount
                                   success:(CDAObjectFetchedBlock)success
                                   failure:(CDARequestFailureBlock)failure {
    NSURLSessionTask* task = [self dataTaskWithRequest:request completionHandler:^(NSURLResponse *r, id responseObject, NSError *error) {
        NSAssert(!r || [r isKindOfClass:NSHTTPURLResponse.class], @"Invalid response.");
        NSHTTPURLResponse* response = (NSHTTPURLResponse*)r;

        if (error) {
            // Rate-Limiting
            if (response.statusCode == 429 && retryCount < 10 && self.rateLimiting) {
                NSUInteger delayInSeconds = 2^retryCount * 100 * 1000;

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)),
                               dispatch_get_main_queue(), ^{
                                   [self sessionTaskWithRequest:request
                                                     retryCount:retryCount + 1
                                                        success:success
                                                        failure:failure];
                               });
                return;
            }

            if (failure) {
                if (CDAClassIsOfType([responseObject class], CDAError.class)) {
                    error = [responseObject errorRepresentationWithCode:response.statusCode];
                }

                failure([CDAResponse responseWithHTTPURLResponse:response], error);
            }
        }

        if (!responseObject && response.statusCode != 204) {
            if (failure) {
                failure([CDAResponse responseWithHTTPURLResponse:response], [NSError errorWithDomain:NSURLErrorDomain code:kCFURLErrorZeroByteResource userInfo:nil]);
            }

            return;
        }

        if (success) {
            success([CDAResponse responseWithHTTPURLResponse:response], responseObject);
        }
    }];

    [task resume];
    return task;
}

@end
