//
//  CDATutorialView.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 22/05/14.
//
//

#import "CDATutorialView.h"
#import "UIView+Geometry.h"

@interface CDATutorialView ()

@property (nonatomic) UIImageView* backgroundImageView;
@property (nonatomic) UILabel* body;
@property (nonatomic) UILabel* headline;
@property (nonatomic) UIImageView* imageView;

@end

#pragma mark -

@implementation CDATutorialView

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.backgroundImageView];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.width - 300.0) / 2, 100.0,
                                                                       300.0, 200.0)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imageView];
        
        self.headline = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 30.0, self.width, 50.0)];
        self.headline.font = [UIFont boldSystemFontOfSize:20.0];
        self.headline.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.headline];
        
        self.body = [[UILabel alloc] initWithFrame:CGRectMake(10.0, CGRectGetMaxY(self.imageView.frame),
                                                              self.width - 20.0, 0.0)];
        self.body.height = self.height - self.body.y;
        self.body.numberOfLines = 0;
        self.body.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.body];
    }
    return self;
}

@end
