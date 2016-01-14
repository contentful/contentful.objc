//
//  CDAAsset.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 05/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAEntry.h>
#import <ContentfulDeliveryAPI/CDANullabilityStubs.h>

#import "CDAPersistedAsset.h"

/** Pass this constant as image quality to not modify the quality. */
extern const CGFloat CDAImageQualityOriginal;

/** Do not round corners (default) */
extern const CGFloat CDARadiusNone;
/** Crop a circle or elipsis instead of rounding corners */
extern const CGFloat CDARadiusMaximum;

/** Enumeration for specifying image formats. */
typedef NS_ENUM(NSInteger, CDAImageFormat) {
    /** JPEG image format */
    CDAImageFormatJPEG,
    /** PNG image format */
    CDAImageFormatPNG,
    /** Keep the original image format */
    CDAImageFormatOriginal,
};

/** Enumeration for specifying resizing behaviour */
typedef NS_ENUM(NSInteger, CDAFitType) {
    /** Keep aspect ratio while fitting the given dimensions */
    CDAFitDefault,
    /** Crop a part of the original image */
    CDAFitCrop,
    /** Scale the image regardless of the original aspect ratio */
    CDAFitScale,
    /** Create a thumbnail of detected faces from image, used with `focus` argument */
    CDAFitThumb,
    /** Same as `CDAFitDefault`, but add padding so that the generated image has the given dimensions */
    CDAFitPad,
    /** Fill the given dimensions by cropping the image */
    CDAFitFill,
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
@property (nonatomic, readonly) NSURL* __nullable URL;

/**
 *  URL for retrieving an image asset which is being resized by the server.
 *
 *  If the asset is not refering an image, this method will return the same the `URL` property.
 *
 *  @param size The desired size of the output image.
 *
 *  @return An URL for retrieving the resized image.
 */
-(NSURL * __nullable)imageURLWithSize:(CGSize)size;

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
-(NSURL * __nullable)imageURLWithSize:(CGSize)size quality:(CGFloat)quality format:(CDAImageFormat)format;

/**
 *  URL for retrieving an image asset which is being processed by the server.
 *
 *  If the asset is not refering an image, this method will return the same the `URL` property.
 *
 *  @param size            The desired size of the output image.
 *  @param quality         The desired quality, with a range from 0.01 to 1.0. Only supported for JPEGs.
 *  @param format          The desired output format or `CDAImageFormatOriginal` if it should not be
 *                         changed.
 *  @param fit             Modify the resizing behaviour (`CDAFitDefault` for default)
 *  @param focus           Specify the focused area of resizing, this can be:
 *                         1. 'top', 'right', 'left', 'bottom'
 *                         2. A combination like 'bottom_right'
 *                         3. 'face' or 'faces' to focus the resizing via face detection
 *                         4. `nil` to use the default
 *  @param radius          Radius for rounded corners, optionally crop a circle/elipsis via 
 *                         `CDARadiusMaximum`. The default is `CDARadiusNone` for not rounding corners.
 *  @param backgroundColor Background color, relevant if the fit type `CDAFitPad` is used. Color
 *                         constant like 'blue' or RGB values like 'rgb:9090ff'. Default: `nil` for
 *                         transparency.
 *  @param progressive     Deliver a progressive image, only supported for JPEGs.
 *
 *  @return An URL for retrieving the processed image.
 */
-(NSURL * __nullable)imageURLWithSize:(CGSize)size
                   quality:(CGFloat)quality
                    format:(CDAImageFormat)format
                       fit:(CDAFitType)fit
                     focus:(NSString* __nullable)focus
                    radius:(CGFloat)radius
                background:(NSString* __nullable)backgroundColor
               progressive:(BOOL)progressive;

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
@property (nonatomic) NSString* __nonnull locale;

/** @name Accessing Meta-Data */

/** All fields associated with this asset. */
@property (nonatomic, readonly) NSDictionary* __nonnull fields;
/** Returns `YES` if this asset is referencing an image file, `NO` otherwise. */
@property (nonatomic, readonly) BOOL isImage;
/** File type of the asset. */
@property (nonatomic, readonly) NSString* __nullable MIMEType;
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
+(NSData* __nullable)cachedDataForAsset:(CDAAsset* __nonnull)asset;

/**
 *  Access previously cached data for an Asset.
 *
 *  @param persistedAsset   The Asset whose cached data should be accessed.
 *  @param client           The client to use for Contentful requests.
 *
 *  @return Cached data or `nil` if none was found.
 */
+(NSData* __nullable)cachedDataForPersistedAsset:(id<CDAPersistedAsset> __nonnull)persistedAsset client:(CDAClient* __nonnull)client;

/**
 *  Cache the data of an Asset to disk.
 *
 *  @param persistedAsset The Asset whose cached data should be cached.
 *  @param client         The client to use for Contentful requests.
 *  @param forceOverwrite If `NO` and file already exists, nothing will be done.
 *  @param handler        This block will be called after persisting the asset.
 */
+(void)cachePersistedAsset:(id<CDAPersistedAsset> __nonnull)persistedAsset
                    client:(CDAClient* __nonnull)client
          forcingOverwrite:(BOOL)forceOverwrite
         completionHandler:(void (^ __nonnull)(BOOL success))handler;

@end
