//
//  CDAClient.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAClient.h>

@class CDAContentTypeRegistry;
@class CDARequestOperationManager;

extern NSString* const CDAContentTypeHeader;
extern NSString* const CMAContentTypeHeader;

@interface CDAClient ()

@property (nonatomic, readonly) BOOL localizationAvailable;
@property (nonatomic, readonly) NSString* protocol;
@property (nonatomic) NSString* resourceClassPrefix;
@property (nonatomic) BOOL synchronizing;

-(CDAConfiguration*)configuration;
-(instancetype)copyWithSpace:(CDASpace*)space;
-(CDAContentTypeRegistry*)contentTypeRegistry;
-(CDARequest*)deleteURLPath:(NSString*)URLPath
                    headers:(NSDictionary*)headers
                 parameters:(NSDictionary*)parameters
                    success:(CDAObjectFetchedBlock)success
                    failure:(CDARequestFailureBlock)failure;
-(CDARequest*)fetchArrayAtURLPath:(NSString *)URLPath
                       parameters:(NSDictionary *)parameters
                          success:(CDAArrayFetchedBlock)success
                          failure:(CDARequestFailureBlock)failure;
-(CDAArray*)fetchAssetsMatching:(NSDictionary*)query synchronouslyWithError:(NSError**)error;
-(CDAArray*)fetchContentTypesMatching:(NSDictionary*)query synchronouslyWithError:(NSError**)error;
-(CDAArray*)fetchEntriesMatching:(NSDictionary*)query synchronouslyWithError:(NSError**)error;
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
-(CDASpace*)space;
-(NSString*)spaceKey;

@end
