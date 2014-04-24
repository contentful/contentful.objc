//
//  UIImageView+CDAAsset.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 13/03/14.
//
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <ContentfulDeliveryAPI/CDAAsset.h>

#import <objc/runtime.h>

#import "CDAAsset+Private.h"
#import "CDAResource+Private.h"
#import "CDAUtilities.h"
#import "UIImageView+CDAAsset.h"

static const char* CDAOfflineCachingKey = "CDAOfflineCachingKey";

@implementation UIImageView (CDAAsset)

-(void)cda_fetchImageWithAsset:(CDAAsset*)asset
                           URL:(NSURL*)URL
              placeholderImage:(UIImage *)placeholderImage {
    __weak typeof(self) weakSelf = self;
    [self setImageWithURLRequest:[NSURLRequest requestWithURL:URL]
                placeholderImage:placeholderImage
                         success:^(NSURLRequest *request, NSHTTPURLResponse *resp, UIImage *image) {
                             __strong typeof(weakSelf) strongSelf = weakSelf;
                             strongSelf.image = image;
                             [strongSelf cda_handleCachingForAsset:asset];
                         } failure:^(NSURLRequest *request, NSHTTPURLResponse *resp, NSError *error) {
                             NSLog(@"Error while request '%@': %@", request.URL, error);
                         }];
}

-(void)cda_handleCachingForAsset:(CDAAsset*)asset {
    if (self.offlineCaching_cda) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [UIImagePNGRepresentation(self.image) writeToFile:CDACacheFileNameForResource(asset)
                                                   atomically:YES];
        });
    }
}

-(void)cda_setImageWithAsset:(CDAAsset*)asset
                         URL:(NSURL*)URL
            placeholderImage:(UIImage *)placeholderImage {
    [self cda_validateAsset:asset];
    
    if (!placeholderImage && self.offlineCaching_cda) {
        NSString* cacheFilePath = CDACacheFileNameForResource(asset);
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath]) {
            placeholderImage = [UIImage imageWithContentsOfFile:cacheFilePath];
            
            NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:cacheFilePath error:nil];
            NSDate *date = [attributes fileModificationDate];
            
            if (![asset updatedAfterDate:date]) {
                [asset.client fetchAssetWithIdentifier:asset.identifier
                                               success:^(CDAResponse *response, CDAAsset *asset) {
                                                   if ([asset updatedAfterDate:date]) {
                                                       [self cda_fetchImageWithAsset:asset
                                                                                 URL:URL
                                                                    placeholderImage:placeholderImage];
                                                   }
                                               } failure:nil];
                
                self.image = placeholderImage;
                return;
            }
        }
    }
    
    [self cda_fetchImageWithAsset:asset URL:URL placeholderImage:placeholderImage];
}

-(void)cda_setImageWithAsset:(CDAAsset *)asset {
    [self cda_setImageWithAsset:asset URL:asset.URL placeholderImage:nil];
}

-(void)cda_setImageWithAsset:(CDAAsset *)asset size:(CGSize)size {
    [self cda_setImageWithAsset:asset URL:[asset imageURLWithSize:size] placeholderImage:nil];
}

-(void)cda_setImageWithAsset:(CDAAsset *)asset placeholderImage:(UIImage *)placeholderImage {
    [self cda_setImageWithAsset:asset URL:asset.URL placeholderImage:placeholderImage];
}

-(void)cda_setImageWithAsset:(CDAAsset *)asset
                        size:(CGSize)size
            placeholderImage:(UIImage *)placeholderImage {
    [self cda_setImageWithAsset:asset
                            URL:[asset imageURLWithSize:size]
               placeholderImage:placeholderImage];
}

-(void)cda_setImageWithPersistedAsset:(id<CDAPersistedAsset>)asset
                               client:(CDAClient*)client
                                 size:(CGSize)size
                     placeholderImage:(UIImage *)placeholderImage {
    [self cda_setImageWithAsset:[CDAAsset assetFromPersistedAsset:asset client:client]
                           size:size
               placeholderImage:placeholderImage];
}

-(void)cda_validateAsset:(CDAAsset *)asset {
    if (!asset.isImage) {
        [NSException raise:NSInvalidArgumentException
                    format:@"Asset %@ is not an image.", asset.identifier];
    }
}

#pragma mark - Properties

-(BOOL)offlineCaching_cda {
    return [objc_getAssociatedObject(self, CDAOfflineCachingKey) boolValue];
}

-(void)setOfflineCaching_cda:(BOOL)cda_offlineCaching {
    objc_setAssociatedObject(self, CDAOfflineCachingKey, @(cda_offlineCaching), OBJC_ASSOCIATION_RETAIN);
}

@end
