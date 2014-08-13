//
//  CDASpace+Private.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 06/03/14.
//
//

#import <ContentfulDeliveryAPI/CDASpace.h>

@interface CDASpace ()

@property (nonatomic) NSString* defaultLocale;
@property (nonatomic, readonly) NSArray* localeCodes;
@property (nonatomic) NSArray* locales;

@end
