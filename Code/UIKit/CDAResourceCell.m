//
//  CDAResourceCell.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 19/03/14.
//
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <ContentfulDeliveryAPI/CDAResourceCell.h>

@interface CDAResourceCell ()

@property (nonatomic) UIImageView* imageView;

@end

#pragma mark -

@implementation CDAResourceCell

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:self.imageView];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
}

-(void)setImageURL:(NSURL *)imageURL {
    if (_imageURL == imageURL) {
        return;
    }
    
    _imageURL = imageURL;
    
    [self.imageView setImageWithURL:imageURL];
}

@end
