//
//  CDARequestOperationManager.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 06/03/14.
//
//

@import Darwin.TargetConditionals;
@import ObjectiveC.runtime;

#import "CDAConfiguration.h"
#import "CDASpace.h"

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
    return [self requestWithMethod:@"GET"
                           URLPath:URLPath
                           headers:nil
                        parameters:parameters
                           success:success
                           failure:failure];

}

-(id)fetchURLPathSynchronously:(NSString*)URLPath
                    parameters:(NSDictionary*)parameters
                         error:(NSError * __autoreleasing *)error {
    NSURLRequest* request = [self buildRequestWithURLString:URLPath parameters:parameters];
    
    NSURLResponse* response;
    NSData *responseData = [CDARequestOperationManager sendSynchronousRequest:request
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

-(instancetype)initWithSpaceKey:(NSString *)spaceKey
                    accessToken:(NSString *)accessToken
                         client:(CDAClient*)client
                  configuration:(CDAConfiguration*)configuration
                   isCMARequest:(BOOL)isCMARequest {
    
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
        self.requestSerializer = [[CDARequestSerializer alloc] initWithAccessToken:accessToken
                                                                      isCMARequest:isCMARequest];
        self.responseSerializer = [[CDAResponseSerializer alloc] initWithClient:client];
        self.rateLimiting = configuration.rateLimiting;

        self.dateFormatter = [NSDateFormatter new];
        NSLocale *posixLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [self.dateFormatter setLocale:posixLocale];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
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
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method
                                                                   URLString:URLString
                                                                  parameters:parameters
                                                                       error:nil];

    [headers enumerateKeysAndObjectsUsingBlock:^(NSString* headerField, NSString* value, BOOL *stop) {
        [request setValue:value forHTTPHeaderField:headerField];
    }];

    [request setValue:CMAContentTypeHeader forHTTPHeaderField:@"Content-Type"];

    NSURLSessionTask* task = [self sessionTaskWithRequest:request
                                               retryCount:0
                                                  success:success
                                                  failure:failure];



    CDARequest *cdaRequest = [[CDARequest alloc] initWithSessionTask:task];

    // Retain the CDAClient in the request.
    CDAClient* client = [(CDAResponseSerializer*)self.responseSerializer client];
    objc_setAssociatedObject(cdaRequest, "client", client, OBJC_ASSOCIATION_RETAIN);

    return cdaRequest;
}

-(NSURLSessionTask*)sessionTaskWithRequest:(NSURLRequest*)request
                                retryCount:(NSUInteger)retryCount
                                   success:(CDAObjectFetchedBlock)success
                                   failure:(CDARequestFailureBlock)failure {
    
    NSURLSessionTask* task = [self dataTaskWithRequest:request
                                        uploadProgress:nil
                                      downloadProgress:nil
                                     completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        NSAssert(!response || [response isKindOfClass:NSHTTPURLResponse.class], @"Invalid response.");
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;

        // Handle failure.
        if (error) {
            // Rate-Limiting
            if (httpResponse.statusCode == 429 && retryCount < 10 && self.rateLimiting) {
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
                    error = [responseObject errorRepresentationWithCode:httpResponse.statusCode];
                }

                failure([CDAResponse responseWithHTTPURLResponse:httpResponse], error);
            }
            return;
        }

        if (!responseObject && httpResponse.statusCode != 204) {
            if (failure) {
                failure([CDAResponse responseWithHTTPURLResponse:httpResponse], [NSError errorWithDomain:NSURLErrorDomain code:kCFURLErrorZeroByteResource userInfo:nil]);
            }
            return;
        }

        // Handle success.
        if (success) {
            success([CDAResponse responseWithHTTPURLResponse:httpResponse], responseObject);
        }
    }];

    [task resume];
    return task;
}


// Synchronous methods don't exist with new NSURLSession API so we must implement it ourselves
// with semaphores«
// Thanks to this SO post: http://stackoverflow.com/a/34200617/4068264
// Categories don't work though: http://stackoverflow.com/a/21685585/4068264
+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request
                 returningResponse:(__autoreleasing NSURLResponse **)responsePtr
                             error:(__autoreleasing NSError **)errorPtr {
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    __block NSData *result = nil;


    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                         if (errorPtr != NULL) {
                                             *errorPtr = error;
                                         }
                                         if (responsePtr != NULL) {
                                             *responsePtr = response;
                                         }
                                         if (error == nil) {
                                             result = data;
                                         }
                                         dispatch_semaphore_signal(sem);
                                     }] resume];

    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);

    return result;
}
@end
