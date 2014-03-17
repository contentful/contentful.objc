//
//  CDAImageViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 17/03/14.
//
//

#import <ContentfulDeliveryAPI/UIImageView+CDAAsset.h>

#import "CDAImageViewController.h"

@interface CDAImageViewController ()

@property (nonatomic) UIImageView* imageView;

@end

#pragma mark -

@implementation CDAImageViewController

-(void)setAsset:(CDAAsset *)asset {
    _asset = asset;
    
    [self.imageView cda_setImageWithAsset:asset];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    
    [self setAsset:self.asset];
}

@end
