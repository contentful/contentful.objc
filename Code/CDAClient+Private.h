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

@property (nonatomic, readonly) NSString* protocol;

-(CDAConfiguration*)configuration;
-(CDAContentTypeRegistry*)contentTypeRegistry;
-(CDARequestOperationManager*)requestOperationManager;

@end
