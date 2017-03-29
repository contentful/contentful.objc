//
//  CDAPersistedAsset.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 14/04/14.
//
//

#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

/**
 *  Any class representing Assets saved to a persistent store needs to conform to this protocol.
 *
 *  If any of the optional properties are implemented, they will automatically be mapped to the
 *  corresponding Asset fields from Contentful.
 */
@protocol CDAPersistedAsset <NSObject>

/** The `sys.id` of the Asset. */
@property (nonatomic, nonnull) NSString* identifier;
/** File type of the Asset. */
@property (nonatomic, nullable) NSString* internetMediaType;
/** URL for the underlying file represented by the Asset. */
@property (nonatomic, nullable) NSString* url;

@optional

/** The description of the Asset. */
@property (nonatomic, nullable) NSString* assetDescription;
/** The title of the Asset. */
@property (nonatomic, nullable) NSString* title;
/** The width of the Asset, if it is an image. */
@property (nonatomic, nullable) NSNumber* width;
/** The height of the Asset, if it is an image. */
@property (nonatomic, nullable) NSNumber* height;

@end
