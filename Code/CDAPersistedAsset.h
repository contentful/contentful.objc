//
//  CDAPersistedAsset.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 14/04/14.
//
//

#import <Foundation/Foundation.h>

/**
 *  Any class representing Assets saved to a persistent store needs to conform to this protocol.
 */
@protocol CDAPersistedAsset <NSObject>

/** The `sys.id` of the Asset. */
@property (nonatomic) NSString* identifier;
/** File type of the Asset. */
@property (nonatomic) NSString* internetMediaType;
/** URL for the underlying file represented by the Asset. */
@property (nonatomic) NSString* url;

@end
