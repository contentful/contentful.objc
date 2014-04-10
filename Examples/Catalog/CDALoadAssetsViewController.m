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
    imageView.offlineCaching_cda = YES;
    [self.view addSubview:imageView];
    
     NSString* cacheFilePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"asset.data"];
    
    self.client = [CDAClient new];
    [self.client fetchEntryWithIdentifier:@"nyancat"
                                  success:^(CDAResponse *response, CDAEntry *entry) {
                                      CDAAsset* asset = entry.fields[@"image"];
                                      [imageView cda_setImageWithAsset:asset];
                                      [asset writeToFile:cacheFilePath];
                                  }
                                  failure:^(CDAResponse *response, NSError *error) {
                                      CDAAsset* asset = [CDAAsset readFromFile:cacheFilePath
                                                                        client:self.client];
                                      [imageView cda_setImageWithAsset:asset];
                                  }];
}

@end
