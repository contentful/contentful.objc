//
//  CDAAssetDetailsViewController.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 02/05/14.
//
//

#import <UIKit/UIKit.h>

@class CDAAsset;

@interface CDAAssetDetailsViewController : UICollectionViewController

-(id)initWithAsset:(CDAAsset*)asset;

@end
