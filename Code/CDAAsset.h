//
//  CDAAsset.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 05/03/14.
//
//

#import "CDAEntry.h"

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

/** @name Accessing Meta-Data */

/** All fields associated with this asset. */
@property (nonatomic, readonly) NSDictionary* fields;
/** File type of the asset. */
@property (nonatomic, readonly) NSString* MIMEType;
/** Size of the asset, if it is an image. */
@property (nonatomic, readonly) CGSize size;

@end
