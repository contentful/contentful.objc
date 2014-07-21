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

#import <objc/runtime.h>

#import "CDAArray+Private.h"
#import "CDAClient+Private.h"
#import "CDAConfiguration.h"
#import "CDAError.h"
#import "CDARequest+Private.h"
#import "CDARequestOperationManager.h"
#import "CDARequestSerializer.h"
#import "CDAResponse+Private.h"
#import "CDAResponseSerializer.h"
#import "CDASpace.h"

@interface CDARequestOperationManager ()

@property (nonatomic) NSString* accessToken;
@property (nonatomic) NSDateFormatter* dateFormatter;

@end

#pragma mark -

@implementation CDARequestOperationManager

-(NSURLRequest*)buildRequestWithURLString:(NSString*)URLString parameters:(NSDictionary*)parameters {
    parameters = [self fixParametersInDictionary:parameters];
    return [[self.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil] copy];
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
                                       error:(NSError **)error {
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
          if (!responseObject) {
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
    
    CDAClient* client = [(CDAResponseSerializer*)self.responseSerializer client];
    objc_setAssociatedObject(operation, "client", client, OBJC_ASSOCIATION_RETAIN);
    
    return [[CDARequest alloc] initWithRequestOperation:operation];
}

-(id)fetchURLPathSynchronously:(NSString*)URLPath
                    parameters:(NSDictionary*)parameters
                         error:(NSError **)error {
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
    mutableParameters[@"access_token"] = self.accessToken;
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString* key, id value, BOOL *stop) {
        if ([value isKindOfClass:[NSArray class]]) {
            mutableParameters[key] = [value componentsJoinedByString:@","];
        }
        
        if ([value isKindOfClass:[NSDate class]]) {
            mutableParameters[key] = [self.dateFormatter stringFromDate:value];
        }
    }];
    
    return [mutableParameters copy];
}

-(AFHTTPRequestOperation *)GET:(NSString *)URLString
                    parameters:(NSDictionary *)parameters
                       success:(void (^)(AFHTTPRequestOperation *, id))success
                       failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    parameters = [self fixParametersInDictionary:parameters];
    return [super GET:URLString parameters:parameters success:success failure:failure];
}

-(id)initWithSpaceKey:(NSString *)spaceKey
          accessToken:(NSString *)accessToken
               client:(CDAClient*)client
        configuration:(CDAConfiguration*)configuration {
    NSString* urlString = [NSString stringWithFormat:@"%@://%@", client.protocol, configuration.server];
    if (spaceKey) {
        urlString = [urlString stringByAppendingFormat:@"/spaces/%@", spaceKey];
    }

    self = [super initWithBaseURL:[NSURL URLWithString:urlString]];
    if (self) {
        self.accessToken = accessToken;
        self.requestSerializer = [CDARequestSerializer new];
        self.responseSerializer = [[CDAResponseSerializer alloc] initWithClient:client];
        
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

@end
