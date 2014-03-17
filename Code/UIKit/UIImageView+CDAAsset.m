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

-(void)cda_setImageWithAsset:(CDAAsset *)asset placeholderImage:(UIImage *)placeholderImage {
    [self cda_validateAsset:asset];
    [self setImageWithURL:asset.URL placeholderImage:placeholderImage];
}

-(void)cda_validateAsset:(CDAAsset *)asset {
    // TODO: Improve validation of assets
    if (![[asset MIMEType] hasPrefix:@"image/"]) {
        [NSException raise:NSInvalidArgumentException
                    format:@"Asset %@ is not an image.", asset.identifier];
    }
}

@end
