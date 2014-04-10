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

#import <ISO8601DateFormatter/ISO8601DateFormatter.h>

#import <objc/runtime.h>

#import "CDAArray+Private.h"
#import "CDAClient+Private.h"
#import "CDAConfiguration.h"
#import "CDAError.h"
#import "CDARequest+Private.h"
#import "CDARequestOperationManager.h"
#import "CDAResponse+Private.h"
#import "CDAResponseSerializer.h"
#import "CDASpace.h"

@interface CDARequestOperationManager ()

@property (nonatomic) NSString* accessToken;
@property (nonatomic) ISO8601DateFormatter* dateFormatter;

@end

#pragma mark -

@implementation CDARequestOperationManager

-(CDARequest*)fetchArrayAtURLPath:(NSString*)URLPath
                parameters:(NSDictionary*)parameters
                   success:(CDAArrayFetchedBlock)success
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
              NSAssert([responseObject isKindOfClass:[CDAArray class]],
                       @"Response object needs to be an array.");
              [(CDAArray*)responseObject setQuery:parameters];
              success([CDAResponse responseWithHTTPURLResponse:operation.response], responseObject);
          }
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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

-(CDARequest*)fetchSpaceWithSuccess:(CDASpaceFetchedBlock)success
                            failure:(CDARequestFailureBlock)failure {
    AFHTTPRequestOperation* operation = [self GET:@"" parameters:nil
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          if (!responseObject) {
              if (failure) {
                  failure([CDAResponse responseWithHTTPURLResponse:operation.response], [NSError errorWithDomain:NSURLErrorDomain code:kCFURLErrorZeroByteResource userInfo:nil]);
              }
              
              return;
          }
          
          if (success) {
              NSAssert([responseObject isKindOfClass:[CDASpace class]],
                       @"Response object needs to be a space.");
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

-(AFHTTPRequestOperation *)GET:(NSString *)URLString
                    parameters:(NSDictionary *)parameters
                       success:(void (^)(AFHTTPRequestOperation *, id))success
                       failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
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
    
    return [super GET:URLString parameters:[mutableParameters copy] success:success failure:failure];
}

-(id)initWithSpaceKey:(NSString *)spaceKey
          accessToken:(NSString *)accessToken
               client:(CDAClient*)client
        configuration:(CDAConfiguration*)configuration {
    NSURL* baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/spaces/%@",
                                           client.protocol, configuration.server, spaceKey]];
    
    self = [super initWithBaseURL:baseURL];
    if (self) {
        self.accessToken = accessToken;
        self.dateFormatter = [ISO8601DateFormatter new];
        self.responseSerializer = [[CDAResponseSerializer alloc] initWithClient:client];
        
        NSString* userAgent = self.requestSerializer.HTTPRequestHeaders[@"User-Agent"];
        userAgent = [userAgent stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
        NSRange bracketRange = [userAgent rangeOfString:@"("];
        [self.requestSerializer setValue:[userAgent stringByReplacingCharactersInRange:NSMakeRange(0, bracketRange.location - 1) withString:@"contentful.objc/0.8.0"]
                      forHTTPHeaderField:@"User-Agent"];
        
#if TARGET_OS_IPHONE
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
#endif
    }
    return self;
}

@end
