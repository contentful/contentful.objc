//
//  CDAContentType.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAResource.h>

@class CDAField;

/**
 Content Types are schemas describing the shape of Entries. They mainly consist of a list of fields 
 acting as a blueprint for Entries.
 
 Note: They're not related to the HTTP Content-Type header.
 */
@interface CDAContentType : CDAResource

/** @name Accessing Fields */

/** List of all fields as an array of `CDAField` objects. */
@property (nonatomic, readonly) NSArray* fields;

/**
 Retrieve a specific field by its identifier.
 
 @param identifier The `sys.id` to look for in the list of fields.
 @return The specific field requested, or `nil` if none matches.
 */
-(CDAField*)fieldForIdentifier:(NSString*)identifier;

/** @name Accessing Meta-Data */

/** The identifier of the Field which should be displayed as a title for Entries */
@property (nonatomic, readonly) NSString* displayField;
/** Name of the Content Type. */
@property (nonatomic, readonly) NSString* name;
/** Description of the Content Type. */
@property (nonatomic, readonly) NSString* userDescription;

@end
