//
//  CDAImageGalleryViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 19/03/14.
//
//

#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>
#import <PDKTCollectionViewWaterfallLayout/PDKTCollectionViewWaterfallLayout.h>

#import "CDAImageGalleryViewController.h"

@interface CDAImageGalleryViewController () <PDKTCollectionViewWaterfallLayoutDelegate>

@property (nonatomic) CDAClient* contentfulClient;

@end

#pragma mark -

@implementation CDAImageGalleryViewController

-(id)init {
    PDKTCollectionViewWaterfallLayout* layout = [PDKTCollectionViewWaterfallLayout new];
    layout.delegate = self;
    
    self = [super initWithCollectionViewLayout:layout cellMapping:@{ @"imageURL": @"URL" }];
    if (self) {
        self.title = NSLocalizedString(@"Mechanical Curator Collection", nil);
        
        CDAConfiguration* configuration = [CDAConfiguration defaultConfiguration];
        configuration.secure = NO;
        configuration.server = @"cdn.flinkly.com";
        self.contentfulClient = [[CDAClient alloc] initWithSpaceKey:@"ygj9clj1hia1" accessToken:@"830722de5ac89040a0094b9d9618b432d2bc745b3f658c6a099c7579087ad801" configuration:configuration];
        self.client = self.contentfulClient;
        
        self.resourceType = CDAResourceTypeAsset;
    }
    return self;
}

#pragma mark - PDKTCollectionViewWaterfallLayoutDelegate

-(CGFloat)collectionView:(UICollectionView *)collectionView
                  layout:(PDKTCollectionViewWaterfallLayout *)collectionViewLayout
 aspectRatioForIndexPath:(NSIndexPath *)indexPath {
    CDAAsset* asset = self.items[indexPath.row];
    return asset.size.width / asset.size.height;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView
                  layout:(PDKTCollectionViewWaterfallLayout *)collectionViewLayout
   heightItemAtIndexPath:(NSIndexPath *)indexPath {
    CDAAsset* asset = self.items[indexPath.row];
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
