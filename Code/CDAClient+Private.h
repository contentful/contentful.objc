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

@interface CDAClient ()

@property (nonatomic) BOOL deepResolving;
@property (nonatomic, readonly) BOOL localizationAvailable;
@property (nonatomic, readonly) NSString* protocol;
@property (nonatomic) BOOL synchronizing;

-(CDAConfiguration*)configuration;
-(CDAContentTypeRegistry*)contentTypeRegistry;
-(CDARequest*)fetchArrayAtURLPath:(NSString *)URLPath
                       parameters:(NSDictionary *)parameters
                          success:(CDAArrayFetchedBlock)success
                          failure:(CDARequestFailureBlock)failure;
-(CDAArray*)fetchAssetsMatching:(NSDictionary*)query synchronouslyWithError:(NSError**)error;
-(CDAArray*)fetchContentTypesMatching:(NSDictionary*)query synchronouslyWithError:(NSError**)error;
-(CDAArray*)fetchEntriesMatching:(NSDictionary*)query synchronouslyWithError:(NSError**)error;
-(CDASpace*)space;

@end
