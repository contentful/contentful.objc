//
//  CDAAssetPreviewController.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 05/05/14.
//
//

#import <QuickLook/QuickLook.h>

@class CDAAsset;
@class CDAAssetPreviewController;

@protocol CDAAssetPreviewControllerDelegate <NSObject>

-(void)assetPreviewControllerDidLoadAssetPreview:(CDAAssetPreviewController*)assetPreviewController;

@end

#pragma mark -

@interface CDAAssetPreviewController : QLPreviewController

@property (nonatomic, weak) id<CDAAssetPreviewControllerDelegate> previewDelegate;

+(BOOL)shouldHandleAsset:(CDAAsset*)asset;

-(id)initWithAsset:(CDAAsset*)asset;

@end
