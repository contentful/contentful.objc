//
//  CDAAsset.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 05/03/14.
//
//

#import "CDAEntry.h"
#import "CDAPersistedAsset.h"

/** Pass this constant as image quality to not modify the quality. */
extern const CGFloat CDAImageQualityOriginal;

/** Enumeration for specifying image formats. */
typedef NS_ENUM(NSInteger, CDAImageFormat) {
    /** JPEG image format */
    CDAImageFormatJPEG,
    /** PNG image format */
    CDAImageFormatPNG,
    /** Keep the original image format */
    CDAImageFormatOriginal,
};

/**
 Assets represent files in a Space. An asset can be any kind of file: an image, a video, an audio file,
 a PDF or any other filetype. Assets are usually attached to Entries through Links.
 
 Assets can optionally be localized by providing separate files for each locale. Those Assets which are
 not localized simply provide a single file under the default locale.
 
 When querying the Content Delivery API for Entries which contain Links to Assets then all Assets will
 be included by default.
 
 Resize image assets on the fly by supplying the desired dimensions as query parameters.
 */
@interface CDAAsset : CDAResource

/** @name Accessing the URL */

/** The URL with which the asset was initialized. (read-only). */
@property (nonatomic, readonly) NSURL* URL;

/**
 *  URL for retrieving an image asset which is being resized by the server.
 *
 *  If the asset is not refering an image, this method will return the same the `URL` property.
 *
 *  @param size The desired size of the output image.
 *
 *  @return An URL for retrieving the resized image.
 */
-(NSURL *)imageURLWithSize:(CGSize)size;

/**
 *  URL for retrieving an image asset which is being processed by the server.
 *
 *  If the asset is not refering an image, this method will return the same the `URL` property.
 *
 *  @param size     The desired size of the output image.
 *  @param quality  The desired quality, with a range from 0.01 to 1.0. Only supported for JPEGs.
 *  @param format   The desired output format or `CDAImageFormatOriginal` if it should not be changed.
 *
 *  @return An URL for retrieving the processed image.
 */
-(NSURL *)imageURLWithSize:(CGSize)size quality:(CGFloat)quality format:(CDAImageFormat)format;

/** @name Accessing Localized Content */

/**
 *  Locale to be used for accessing any values of `fields`.
 *
 *  By default, this will be set to the Space's default locale. If set to a non-existing locale, it
 *  will automatically revert to the default value.
 *
 *  Changing this property only has an effect if the receiver was obtained from a `CDASyncedSpace`
 *  originally. Assets obtained any other way will only contain values for the locale specified in
 *  the query or for the default locale. In addition to that, this properties value will also only
 *  be accurate for Assets obtained from a `CDASyncedSpace`originally.
 *
 */
@property (nonatomic) NSString* locale;

/** @name Accessing Meta-Data */

/** All fields associated with this asset. */
@property (nonatomic, readonly) NSDictionary* fields;
/** Returns `YES` if this asset is referencing an image file, `NO` otherwise. */
@property (nonatomic, readonly) BOOL isImage;
/** File type of the asset. */
@property (nonatomic, readonly) NSString* MIMEType;
/** Size of the asset, if it is an image. */
@property (nonatomic, readonly) CGSize size;

/** @name Creating and Accessing Cached Data */

/**
 *  Access previously cached data for an Asset.
 *
 *  @param asset The Asset whose cached data should be accessed.
 *
 *  @return Cached data or `nil` if none was found.
 */
+(NSData*)cachedDataForAsset:(CDAAsset*)asset;

/**
 *  Access previously cached data for an Asset.
 *
 *  @param persistedAsset   The Asset whose cached data should be accessed.
 *  @param client           The client to use for Contentful requests.
 *
 *  @return Cached data or `nil` if none was found.
 */
+(NSData*)cachedDataForPersistedAsset:(id<CDAPersistedAsset>)persistedAsset client:(CDAClient*)client;

/**
 *  Cache the data of an Asset to disk.
 *
 *  @param persistedAsset The Asset whose cached data should be cached.
 *  @param client         The client to use for Contentful requests.
 *  @param forceOverwrite If `NO` and file already exists, nothing will be done.
 *  @param handler        This block will be called after persisting the asset.
 */
+(void)cachePersistedAsset:(id<CDAPersistedAsset>)persistedAsset
                    client:(CDAClient*)client
          forcingOverwrite:(BOOL)forceOverwrite
         completionHandler:(void (^)(BOOL success))handler;

@end
