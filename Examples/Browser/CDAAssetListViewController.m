//
//  CDAAssetListViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 02/05/14.
//
//

#import <PDKTCollectionViewWaterfallLayout/PDKTCollectionViewWaterfallLayout.h>

#import "CDAAssetDetailsViewController.h"
#import "CDAAssetListViewController.h"
#import "UIApplication+Browser.h"

@interface CDAAssetListViewController () <PDKTCollectionViewWaterfallLayoutDelegate>

@end

@implementation CDAAssetListViewController

-(id)init {
    PDKTCollectionViewWaterfallLayout* layout = [PDKTCollectionViewWaterfallLayout new];
    layout.delegate = self;
    
    self = [super initWithCollectionViewLayout:layout cellMapping:@{ @"imageURL": @"URL" }];
    if (self) {
        self.client = [UIApplication sharedApplication].client;
        self.collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.resourceType = CDAResourceTypeAsset;
        self.title = NSLocalizedString(@"Assets", nil);
    }
    return self;
}

#pragma mark - PDKTCollectionViewWaterfallLayoutDelegate

-(CGFloat)collectionView:(UICollectionView *)collectionView
                  layout:(PDKTCollectionViewWaterfallLayout *)collectionViewLayout
 aspectRatioForIndexPath:(NSIndexPath *)indexPath {
    CDAAsset* asset = self.items[indexPath.row];
    CGFloat aspectRatio = asset.size.width / asset.size.height;
    return isnan(aspectRatio) ? 1.0 : aspectRatio;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView
                  layout:(PDKTCollectionViewWaterfallLayout *)collectionViewLayout
   heightItemAtIndexPath:(NSIndexPath *)indexPath {
    CDAAsset* asset = self.items[indexPath.row];
    CGFloat height = asset.size.height;
    return isnan(height) ? 0.0 : height;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView
                  layout:(PDKTCollectionViewWaterfallLayout *)collectionViewLayout
    itemSpacingInSection:(NSUInteger)section {
    return 10.0;
}

-(NSUInteger)collectionView:(UICollectionView *)collectionView
                     layout:(PDKTCollectionViewWaterfallLayout *)collectionViewLayout
   numberOfColumnsInSection:(NSUInteger)section {
    return 3;
}

#pragma mark - UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)cv didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CDAAsset* asset = self.items[indexPath.row];
    CDAAssetDetailsViewController* details = [[CDAAssetDetailsViewController alloc] initWithAsset:asset];
    [self.navigationController pushViewController:details animated:YES];
}

@end
