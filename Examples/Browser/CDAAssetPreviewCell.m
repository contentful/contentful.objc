//
//  CDAAssetPreviewCell.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 05/05/14.
//
//

#import "CDAAssetPreviewCell.h"

@interface CDAAssetPreviewCell ()

@end

#pragma mark -

@implementation CDAAssetPreviewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

- (void)layoutSubviews {
    self.imageView.frame = self.bounds;
    [self.contentView bringSubviewToFront:self.imageView];
}

@end
