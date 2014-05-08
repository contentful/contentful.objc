//
//  CDAAssetThumbnailOperation.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 05/05/14.
//
//

#import "CDAAssetPreviewController.h"
#import "CDAAssetThumbnailOperation.h"
#import "UIImage+AverageColor.h"

@interface CDAAssetThumbnailOperation () <CDAAssetPreviewControllerDelegate> {
    BOOL _isExecuting;
    BOOL _isFinished;
}

@property (nonatomic) CDAAsset* asset;
@property (nonatomic) CDAAssetPreviewController* previewController;
@property (nonatomic) UIImage* snapshot;
@property (nonatomic) CGSize thumbnailSize;

@end

#pragma mark -

@implementation CDAAssetThumbnailOperation

-(void)finish {
    self.previewController = nil;
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    _isExecuting = NO;
    _isFinished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

-(id)initWithAsset:(CDAAsset*)asset thumbnailSize:(CGSize)thumbnailSize {
    self = [super init];
    if (self) {
        self.asset = asset;
        self.thumbnailSize = thumbnailSize;
        
        _isExecuting = NO;
        _isFinished = NO;
    }
    return self;
}

-(BOOL)isConcurrent {
    return YES;
}

-(BOOL)isExecuting {
    return _isExecuting;
}

-(BOOL)isFinished {
    return _isFinished;
}

-(UIImage *)snapshot {
    if (!_snapshot || [_snapshot isBlack]) {
        return [UIImage imageNamed:@"document"];
    }
    
    return _snapshot;
}

-(UIImage *)snapshot:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(void)start {
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    if (![CDAAssetPreviewController shouldHandleAsset:self.asset]) {
        [self finish];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.previewController = [[CDAAssetPreviewController alloc] initWithAsset:self.asset];
        self.previewController.previewDelegate = self;
        self.previewController.view.frame = CGRectMake(0.0, 0.0,
                                                       self.thumbnailSize.width,
                                                       self.thumbnailSize.height);
        [self.previewController viewWillAppear:NO];
    });
}

#pragma mark - CDAAssetPreviewControllerDelegate

-(void)assetPreviewControllerDidLoadAssetPreview:(CDAAssetPreviewController *)assetPreviewController {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),
                   ^{
                       self.snapshot = [self snapshot:assetPreviewController.view];
                       
                       [self finish];
                   });
}

@end
