//
//  CDAField.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

@import Foundation;

/**
 Possible field types.
 
 [For further reference](https://www.contentful.com/developers/documentation/content-delivery-api/#content-type-fields)
 */
typedef NS_ENUM(NSInteger, CDAFieldType) {
    /** List of values. Value type depends on `itemType` property. */
    CDAFieldTypeArray,
    /** Flag, represented as a `BOOL`. */
    CDAFieldTypeBoolean,
    /** Date, represented as an `NSDate` instance. */
    CDAFieldTypeDate,
    /** Number type without decimals. Values from -2^53 to 2^53. */
    CDAFieldTypeInteger,
    /** Links represent relationships between Resources. */
    CDAFieldTypeLink,
    /** A location coordinate, values should be retrieved using the `-CLLocationCoordinate2DFromFieldWithIdentifier:` of `CDAEntry`. */
    CDAFieldTypeLocation,
    /** Unspecified, used to denominate the `itemType` of any field which is not an array. */
    CDAFieldTypeNone,
    /** Number type with decimals. */
    CDAFieldTypeNumber,
    /** JSON object. */
    CDAFieldTypeObject,
    /** Basic list of characters. */
    CDAFieldTypeSymbol,
    /** Same as String, but can be filtered via [Full-Text Search](https://www.contentful.com/developers/documentation/content-delivery-api/#search-filter-full-text). */
    CDAFieldTypeText,
    /** Used as `itemType` for arrays of entries or as `type` for links. */
    CDAFieldTypeEntry,
    /** Used as `itemType` for arrays of assets or as `type` for links. */
    CDAFieldTypeAsset,
};

/** A `CDAField` describes a single property of a `CDAEntry`. */
@interface CDAField : NSObject <NSCoding, NSSecureCoding>

/** @name Accessing Field Information */

/** Unique ID of the field. */
@property (nonatomic, readonly) NSString* identifier;
/** Name of the field. */
@property (nonatomic, readonly) NSString* name;
/** Type of the field. */
@property (nonatomic, readonly) CDAFieldType type;
/** Whether the field was disabled. */
@property (nonatomic, readonly) BOOL disabled;

/** @name Accessing the Type of Array Items */

/** Field type of items if the field is an Array, `CDAFieldTypeNone` otherwise. */
@property (nonatomic, readonly) CDAFieldType itemType;

@end
