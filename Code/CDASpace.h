//
//  CDASpace.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 06/03/14.
//
//

#import <ContentfulDeliveryAPI/CDANullabilityStubs.h>
#import <ContentfulDeliveryAPI/CDAResource.h>

/**
 Spaces are containers for Content Types, Entries and Assets.
 */
@interface CDASpace : CDAResource

/** @name Accessing Meta-Data */

/** Default locale for this Space. */
@property (nonatomic, readonly) NSString* __nonnull defaultLocale;
/** Possible locales used for Entries in this Space. */
@property (nonatomic, readonly) NSArray* __nullable locales;
/** The name of this Space. */
@property (nonatomic, readonly) NSString* __nullable name;

@end
