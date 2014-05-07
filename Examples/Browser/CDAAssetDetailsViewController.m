//
//  CDAAssetDetailsViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 02/05/14.
//
//

#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>
#import <ContentfulDeliveryAPI/UIImageView+CDAAsset.h>
#import <CSStickyHeaderFlowLayout/CSStickyHeaderFlowLayout.h>

#import "CDAAssetDetailsViewController.h"
#import "CDABasicCell.h"
#import "CDAHeaderView.h"

@interface CDAAssetDetailsViewController ()

@property (nonatomic) CDAAsset* asset;
@property (nonatomic) NSArray* keyPathsOrder;
@property (nonatomic) NSDictionary* keyPathsToShow;

@end

#pragma mark -

@implementation CDAAssetDetailsViewController

-(id)initWithAsset:(CDAAsset*)asset {
    CSStickyHeaderFlowLayout* layout = [CSStickyHeaderFlowLayout new];
    layout.disableStickyHeaders = YES;
    layout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 44.0);
    layout.minimumLineSpacing = 0.0;
    layout.parallaxHeaderReferenceSize = CGSizeMake(layout.itemSize.width, 200.0);
    
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        self.asset = asset;
        self.title = self.asset.fields[@"title"];
        
        self.keyPathsOrder = @[ @"fields.title", @"fields.description", @"sys.createdAt",
                                @"fields.file.contentType", @"fields.file.details.size", @"size" ];
        self.keyPathsToShow = @{ @"fields.title": NSLocalizedString(@"Title", nil),
                                 @"sys.createdAt": NSLocalizedString(@"Creation Date", nil),
                                 @"fields.file.contentType": NSLocalizedString(@"MIME Type", nil),
                                 @"fields.file.details.size": NSLocalizedString(@"Size", nil),
                                 @"size": NSLocalizedString(@"Image dimensions", nil),
                                 @"fields.description": NSLocalizedString(@"Description", nil) };
        
        NSAssert([[NSSet setWithArray:self.keyPathsOrder]
                  isEqualToSet:[NSSet setWithArray:self.keyPathsToShow.allKeys]],
                 @"Keypath sets are not equivalent.");
        
        self.collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.collectionView.bounces = YES;
        self.collectionView.alwaysBounceVertical = YES;
        
        [self.collectionView registerClass:[CDABasicCell class]
                forCellWithReuseIdentifier:NSStringFromClass([self class])];
        [self.collectionView registerClass:[CDAHeaderView class]
                forSupplementaryViewOfKind:CSStickyHeaderParallaxHeader
                       withReuseIdentifier:NSStringFromClass([self class])];
    }
    return self;
}

#pragma mark - UICollectionViewDataSource

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CDABasicCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self class])
                                                                   forIndexPath:indexPath];
    
    NSString* key = self.keyPathsOrder[indexPath.row];
    cell.detailTextLabel.text = [[self.asset valueForKeyPath:key] description];
    cell.textLabel.text = self.keyPathsToShow[key];
    
    if (indexPath.row == 0) {
        cell.cellType = CDACellTypeFirst;
    }
    
    if (indexPath.row == [self collectionView:collectionView
                       numberOfItemsInSection:indexPath.section] - 1) {
        cell.cellType = CDACellTypeLast;
    }
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.keyPathsOrder.count;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
          viewForSupplementaryElementOfKind:(NSString *)kind
                                atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:CSStickyHeaderParallaxHeader]) {
        CDAHeaderView* headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                       withReuseIdentifier:NSStringFromClass([self class])
                                                                              forIndexPath:indexPath];
        [headerView.imageView cda_setImageWithAsset:self.asset];
        return headerView;
    }
    
    return nil;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

@end
