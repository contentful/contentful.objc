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
#import "CDAAssetPreviewController.h"
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
    layout.parallaxHeaderReferenceSize = CGSizeMake(layout.itemSize.width, 300.0);
    
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

#pragma mark - Actions

-(void)documentTapped {
    CDAAssetPreviewController* preview = [[CDAAssetPreviewController alloc] initWithAsset:self.asset];
    [self.navigationController pushViewController:preview animated:YES];
}

#pragma mark - UICollectionViewDataSource

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CDABasicCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self class])
                                                                   forIndexPath:indexPath];
    
    NSString* key = self.keyPathsOrder[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = self.keyPathsToShow[key];
    
    if ([key isEqualToString:@"fields.file.details.size"]) {
        long long byteCount = [[self.asset valueForKeyPath:key] longLongValue];
        cell.detailTextLabel.text = [NSByteCountFormatter stringFromByteCount:byteCount countStyle:NSByteCountFormatterCountStyleFile];
    } else if ([key isEqualToString:@"size"]) {
        cell.detailTextLabel.text = NSStringFromCGSize([[self.asset valueForKeyPath:key] CGSizeValue]);
    } else if ([key isEqualToString:@"sys.createdAt"]) {
        cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:[self.asset valueForKeyPath:key]
                                                                   dateStyle:NSDateFormatterMediumStyle
                                                                   timeStyle:NSDateFormatterShortStyle];
    } else {
        cell.detailTextLabel.text = [[self.asset valueForKeyPath:key] description];
    }
    
    if ([key isEqualToString:@"fields.title"]) {
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:16.0];
        cell.detailTextLabel.textColor = [UIColor blackColor];
    }
    
    if ([@[ @"fields.description", @"fields.title" ] containsObject:key]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
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
    return self.keyPathsOrder.count - (self.asset.isImage ? 0 : 1);
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
          viewForSupplementaryElementOfKind:(NSString *)kind
                                atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:CSStickyHeaderParallaxHeader]) {
        CDAHeaderView* headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                       withReuseIdentifier:NSStringFromClass([self class])
                                                                              forIndexPath:indexPath];
        
        if (self.asset.isImage) {
            CGFloat size = 300.0 * [UIScreen mainScreen].scale;
            [headerView.imageView cda_setImageWithAsset:self.asset size:CGSizeMake(size, size)];
        } else {
            headerView.imageView.image = self.fallbackImage;
            headerView.imageView.userInteractionEnabled = YES;
            
            [headerView.imageView addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                                        initWithTarget:self
                                                        action:@selector(documentTapped)]];
        }
        
        return headerView;
    }
    
    return nil;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

#pragma mark - UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString* key = self.keyPathsOrder[indexPath.row];
    NSString* value = [self.asset valueForKeyPath:key];
    
    if ([@[ @"fields.description", @"fields.title" ] containsObject:key]) {
        UIViewController* text = [NSClassFromString(@"CDATextViewController") new];
        text.title = self.keyPathsToShow[key];
        [(id)text setText:value];
        [self.navigationController pushViewController:text animated:YES];
    }
}

@end
