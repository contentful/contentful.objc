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

-(void)dealloc {
    [self.imageView removeObserver:self forKeyPath:@"image"];
}

-(UIImageView *)imageView {
    if (_imageView) {
        return _imageView;
    }
    
    _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_imageView];
    
    [_imageView addObserver:self forKeyPath:@"image" options:0 context:NULL];
    
    return _imageView;
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(UIImageView*)imageView
                       change:(NSDictionary *)change
                      context:(void *)context {
    if (imageView.image.images) {
        [imageView startAnimating];
    }
}

@end
