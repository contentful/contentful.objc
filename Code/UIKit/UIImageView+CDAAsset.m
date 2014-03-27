//
//  UIImageView+CDAAsset.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 13/03/14.
//
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <ContentfulDeliveryAPI/CDAAsset.h>

#import "UIImageView+CDAAsset.h"

@implementation UIImageView (CDAAsset)

-(void)cda_setImageWithAsset:(CDAAsset *)asset {
    [self cda_validateAsset:asset];
    [self setImageWithURL:asset.URL];
}

-(void)cda_setImageWithAsset:(CDAAsset *)asset size:(CGSize)size {
    [self cda_validateAsset:asset];
    [self setImageWithURL:[asset imageURLWithSize:size]];
}

-(void)cda_setImageWithAsset:(CDAAsset *)asset placeholderImage:(UIImage *)placeholderImage {
    [self cda_validateAsset:asset];
    [self setImageWithURL:asset.URL placeholderImage:placeholderImage];
}

-(void)cda_setImageWithAsset:(CDAAsset *)asset
                        size:(CGSize)size
            placeholderImage:(UIImage *)placeholderImage {
    [self cda_validateAsset:asset];
    [self setImageWithURL:[asset imageURLWithSize:size] placeholderImage:placeholderImage];
}

-(void)cda_validateAsset:(CDAAsset *)asset {
    if (!asset.isImage) {
        [NSException raise:NSInvalidArgumentException
                    format:@"Asset %@ is not an image.", asset.identifier];
    }
}

@end
