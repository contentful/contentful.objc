//
//  CDAAssetThumbnailOperation.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 05/05/14.
//
//

#import <Foundation/Foundation.h>

@interface CDAAssetThumbnailOperation : NSOperation

@property (nonatomic, readonly) UIImage* snapshot;

-(id)initWithAsset:(CDAAsset*)asset thumbnailSize:(CGSize)thumbnailSize;

@end
