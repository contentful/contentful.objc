//
//  CMALocale.h
//  Pods
//
//  Created by Boris Bügling on 08/08/14.
//
//

#import <ContentfulDeliveryAPI/CDANullabilityStubs.h>
#import <ContentfulManagementAPI/ContentfulManagementAPI.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Models the localization of a space into one specific language.
 */
@interface CMALocale : CDAResource <CMAResource>

/**
 *  The country-code of the receiver.
 */
@property (nonatomic, readonly) NSString* code;

/**
 *  Whether or not the receiver is the default locale of its space.
 */
@property (nonatomic, readonly, getter = isDefault) BOOL defaultLocale;

/**
 *  The name of the receiver.
 */
@property (nonatomic) NSString* name;

/**
 *  Whether or not the receiver is an optional locale.
 *
 *  Optional locales do not need values for required fields to publish an entry.
 */
@property (nonatomic, getter = isOptional) BOOL optional;

@end

NS_ASSUME_NONNULL_END
