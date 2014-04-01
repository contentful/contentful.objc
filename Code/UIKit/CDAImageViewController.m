//
//  CDAImageViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 17/03/14.
//
//

#import <ContentfulDeliveryAPI/CDAAsset.h>
#import <ContentfulDeliveryAPI/UIImageView+CDAAsset.h>

#import "CDAImageViewController.h"

@interface CDAImageViewController ()

@property (nonatomic) UIImageView* imageView;

@end

#pragma mark -

@implementation CDAImageViewController

-(void)setAsset:(CDAAsset *)asset {
    _asset = asset;
    
    if (asset.isImage) {
        [self.imageView cda_setImageWithAsset:asset];
    } else {
        self.imageView.hidden = YES;
    }
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel* unsupportedAssetTypeLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
    unsupportedAssetTypeLabel.backgroundColor = self.view.backgroundColor;
    unsupportedAssetTypeLabel.text = NSLocalizedString(@"Unsupported asset type.", nil);
    unsupportedAssetTypeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:unsupportedAssetTypeLabel];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.imageView.backgroundColor = self.view.backgroundColor;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    
    [self setAsset:self.asset];
}

@end
