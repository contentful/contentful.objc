//
//  CDALoadAssetsViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 17/03/14.
//
//

#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>
#import <ContentfulDeliveryAPI/UIImageView+CDAAsset.h>

#import "CDALoadAssetsViewController.h"

@interface CDALoadAssetsViewController ()

@property (nonatomic) CDAClient* client;

@end

#pragma mark -

@implementation CDALoadAssetsViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    
    self.client = [CDAClient new];
    [self.client fetchEntryWithIdentifier:@"nyancat"
                                  success:^(CDAResponse *response, CDAEntry *entry) {
                                      [imageView cda_setImageWithAsset:entry.fields[@"image"]];
                                  }
                                  failure:nil];
}

@end
