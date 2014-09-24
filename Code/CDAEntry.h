//
//  CDAEntry.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

@import MapKit;

#import <ContentfulDeliveryAPI/CDAResource.h>

@class CDAContentType;

/** 
 Entries represent textual content in a Space. An Entry's data adheres to a certain Content Type.
 */
@interface CDAEntry : CDAResource

/** @name Accessing Fields */

/** Properties according to Content Type. */
@property (nonatomic, readonly) NSDictionary* fields;

/**
 Retrieve the value of a specific Field as a `CLLocationCoordinate2D` for easy interaction with
 CoreLocation or MapKit.
 
 @param identifier  The `sys.id` of the Field which should be queried.
 @return The actual location value of the Field.
 @exception NSIllegalArgumentException If the specified Field is not of type Location.
 */
-(CLLocationCoordinate2D)CLLocationCoordinate2DFromFieldWithIdentifier:(NSString*)identifier;

/** @name Accessing Content Types */

/** The Entry's Content Type. */
@property (nonatomic, readonly) CDAContentType* contentType;

/** @name Accessing Localized Content */

/**
 *  Locale to be used for accessing any values of `fields`.
 *
 *  By default, this will be set to the Space's default locale. If set to a non-existing locale, it
 *  will automatically revert to the default value. 
 *
 *  Changing this property only has an effect if the receiver was obtained from a `CDASyncedSpace`
 *  originally. Entries obtained any other way will only contain values for the locale specified in 
 *  the query or for the default locale. In addition to that, this properties value will also only
 *  be accurate for Entries obtained from a `CDASyncedSpace`originally.
 *
 */
@property (nonatomic) NSString* locale;

/** @name Handle custom objects */

/**
 *  Copy a set of Field values from this Entry to any custom object you provide. The mapping is 
 *  supposed to map a keypath on this Entry to a keypath on `object`.
 *
 *  This can be used as a quick way to fill your own value objects with data from Entries fetched 
 *  from the Contentful API, e.g. if you want to use Core Data in your app.
 *
 *  Currently, this method does no conversion or error checking on top of what is already provided by
 *  Key-Value-Coding. However, it will skip all relations to other Resources, because those will
 *  likely need special behaviour.
 *
 *  Example:
 *
 *      `[someEntry mapFieldsToObject:someObject usingMapping:@{ @"fields.name": @"name" }];
 *
 *  @param object     The target object which is supposed to be filled with data.
 *  @param dictionary A dictionary described the mapping between keypaths on the Entry and 
 *      keypaths on the `object` parameter.
 *
 *  @return To make one line mappings possible, this method returns the `object` parameter.
 */
-(id)mapFieldsToObject:(NSObject*)object usingMapping:(NSDictionary*)dictionary;

@end
