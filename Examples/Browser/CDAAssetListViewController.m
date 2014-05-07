//
//  CDAAssetListViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 02/05/14.
//
//

#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>
#import <PDKTCollectionViewWaterfallLayout/PDKTCollectionViewWaterfallLayout.h>

#import "CDAAssetDetailsViewController.h"
#import "CDAAssetListViewController.h"
#import "CDAAssetPreviewController.h"
#import "CDAAssetThumbnailOperation.h"
#import "UIApplication+Browser.h"

#define CDADocumentThumbnailSize        CGSizeMake(100.0, 200.0)

@interface CDAAssetListViewController () <PDKTCollectionViewWaterfallLayoutDelegate>

@property (nonatomic) NSOperationQueue* thumbnailQueue;

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
        self.thumbnailQueue = [NSOperationQueue new];
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

#pragma mark - UICollectionViewDataSource

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CDAAsset* asset = self.items[indexPath.row];
    CDAResourceCell* cell = (CDAResourceCell*)[super collectionView:collectionView
                                             cellForItemAtIndexPath:indexPath];
    
    if (!asset.isImage) {
        CDAAssetThumbnailOperation* operation = [[CDAAssetThumbnailOperation alloc] initWithAsset:asset thumbnailSize:CDADocumentThumbnailSize];
        
        __weak typeof(CDAAssetThumbnailOperation*) weakOperation = operation;
        operation.completionBlock = ^{
            dispatch_sync(dispatch_get_main_queue(), ^{
                cell.imageView.image = weakOperation.snapshot;
            });
        };
        
        [self.thumbnailQueue addOperation:operation];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)cv didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CDAAsset* asset = self.items[indexPath.row];
    
    if (asset.isImage) {
        CDAAssetDetailsViewController* details = [[CDAAssetDetailsViewController alloc] initWithAsset:asset];
        [self.navigationController pushViewController:details animated:YES];
    } else {
        CDAAssetPreviewController* preview = [[CDAAssetPreviewController alloc] initWithAsset:asset];
        [self.navigationController pushViewController:preview animated:YES];
    }
}

@end
