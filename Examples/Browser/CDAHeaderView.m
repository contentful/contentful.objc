//
//  CDAHeaderView.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 02/05/14.
//
//

#import "CDAHeaderView.h"

@implementation CDAHeaderView

@synthesize imageView = _imageView;

#pragma mark -

-(UIImageView *)imageView {
    if (_imageView) {
        return _imageView;
    }
    
    _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_imageView];
    
    return _imageView;
}

@end
