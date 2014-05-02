//
//  CDASpaceViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 30/04/14.
//
//

#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>
#import <PDKTCollectionViewWaterfallLayout/PDKTCollectionViewWaterfallLayout.h>

#import "CDASpaceViewController.h"
#import "UIApplication+Browser.h"

@interface CDASpaceViewController () <PDKTCollectionViewWaterfallLayoutDelegate>

@property (nonatomic, readonly) CDAResourcesCollectionViewController* assets;
@property (nonatomic, readonly) CDAResourcesViewController* contentTypes;

@end

#pragma mark -

@implementation CDASpaceViewController

@synthesize assets = _assets;
@synthesize contentTypes = _contentTypes;

#pragma mark -

-(CDAResourcesCollectionViewController *)assets {
    if (_assets) {
        return _assets;
    }
    
    PDKTCollectionViewWaterfallLayout* layout = [PDKTCollectionViewWaterfallLayout new];
    layout.delegate = self;
    
    _assets = [[CDAResourcesCollectionViewController alloc] initWithCollectionViewLayout:layout cellMapping:@{ @"imageURL": @"URL" }];
    _assets.client = [UIApplication sharedApplication].client;
    _assets.collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _assets.resourceType = CDAResourceTypeAsset;
    _assets.title = NSLocalizedString(@"Assets", nil);
    
    return _assets;
}

-(UIViewController *)contentTypes {
    if (_contentTypes) {
        return _contentTypes;
    }
    
    _contentTypes = [[CDAResourcesViewController alloc] initWithCellMapping:@{ @"textLabel.text": @"name" }];
    _contentTypes.client = [UIApplication sharedApplication].client;
    _contentTypes.resourceType = CDAResourceTypeContentType;
    _contentTypes.title = NSLocalizedString(@"Entries", nil);
    
    [_contentTypes.client fetchSpaceWithSuccess:^(CDAResponse *response, CDASpace *space) {
        _contentTypes.navigationItem.title = space.name;
    } failure:nil];
    
    return _contentTypes;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewControllers = @[ [[UINavigationController alloc] initWithRootViewController:self.contentTypes],
                              [[UINavigationController alloc] initWithRootViewController:self.assets] ];
}

#pragma mark - PDKTCollectionViewWaterfallLayoutDelegate

-(CGFloat)collectionView:(UICollectionView *)collectionView
                  layout:(PDKTCollectionViewWaterfallLayout *)collectionViewLayout
 aspectRatioForIndexPath:(NSIndexPath *)indexPath {
    CDAAsset* asset = self.assets.items[indexPath.row];
    return asset.size.width / asset.size.height;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView
                  layout:(PDKTCollectionViewWaterfallLayout *)collectionViewLayout
   heightItemAtIndexPath:(NSIndexPath *)indexPath {
    CDAAsset* asset = self.assets.items[indexPath.row];
    return asset.size.height;
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

@end
