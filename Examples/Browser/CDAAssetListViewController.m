//
//  CDAAssetListViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 02/05/14.
//
//

#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>

#import "CDAAssetDetailsViewController.h"
#import "CDAAssetListViewController.h"
#import "CDAAssetThumbnailOperation.h"
#import "UIApplication+Browser.h"

#define CDADocumentThumbnailSize        CGSizeMake(100.0 * [UIScreen mainScreen].scale, \
                                                   100.0 * [UIScreen mainScreen].scale)

@interface CDAAssetListViewController ()

@property (nonatomic) NSOperationQueue* thumbnailQueue;

@end

@implementation CDAAssetListViewController

- (UIImage *)imageByCroppingImage:(UIImage *)image toSize:(CGSize)size {
    CGFloat x = (image.size.width - size.width) / 2.0;
    CGFloat y = (image.size.height - size.height) / 2.0;
    
    CGRect cropRect = CGRectMake(x, y, size.height, size.width);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropped;
}

-(id)init {
    UICollectionViewFlowLayout* layout = [UICollectionViewFlowLayout new];
    layout.headerReferenceSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 54.0);
    layout.itemSize = CGSizeMake(100.0, 100.0);
    layout.minimumInteritemSpacing = 10.0;
    layout.minimumLineSpacing = 10.0;
    
    self = [super initWithCollectionViewLayout:layout cellMapping:nil];
    if (self) {
        self.client = [UIApplication sharedApplication].client;
        self.collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.resourceType = CDAResourceTypeAsset;
        self.showSearchBar = YES;
        self.tabBarItem.image = [UIImage imageNamed:@"assets"];
        self.thumbnailQueue = [NSOperationQueue new];
        self.thumbnailQueue.maxConcurrentOperationCount = 1;
        self.title = NSLocalizedString(@"Assets", nil);
    }
    return self;
}

#pragma mark - UICollectionViewDataSource

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CDAAsset* asset = self.items[indexPath.row];
    CDAResourceCell* cell = (CDAResourceCell*)[super collectionView:collectionView
                                             cellForItemAtIndexPath:indexPath];
    
    if (asset.isImage) {
        CGFloat height = ceilf(CDADocumentThumbnailSize.width / asset.size.width * asset.size.height);
        NSURL* imageURL = [asset imageURLWithSize:CGSizeMake(CDADocumentThumbnailSize.width, height)
                                          quality:0.7
                                           format:CDAImageFormatJPEG];
        
        cell.clipsToBounds = YES;
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:imageURL]
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response,
                                                   NSData *data,
                                                   NSError *connectionError) {
                                   if (data) {
                                       UIImage* image = [UIImage imageWithData:data];
                                       image = [self imageByCroppingImage:image
                                                                   toSize:CDADocumentThumbnailSize];
                                       
                                       cell.imageView.image = image;
                                   }
                               }];
        
    } else {
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
    CDAResourceCell* cell = (CDAResourceCell*)[cv cellForItemAtIndexPath:indexPath];
    
    CDAAssetDetailsViewController* details = [[CDAAssetDetailsViewController alloc] initWithAsset:asset];
    [self.navigationController pushViewController:details animated:YES];
    
    if (!asset.isImage) {
        details.fallbackImage = cell.imageView.image;
    }
}

@end
