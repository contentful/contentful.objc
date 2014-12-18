//
//  UIImageView+CDAAsset.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 13/03/14.
//
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <ContentfulDeliveryAPI/CDAAsset.h>

@import ObjectiveC.runtime;

#import "CDAAsset+Private.h"
#import "CDAResource+Private.h"
#import "CDAUtilities.h"
#import "UIImageView+CDAAsset.h"

static const char* CDAOfflineCachingKey = "CDAOfflineCachingKey";
static const char* CDAProgressViewKey   = "CDAProgressViewKey";

@interface UIImageView ()

@property (nonatomic) UIActivityIndicatorView* progressView_cda;

@end

#pragma mark -

@implementation UIImageView (CDAAsset)

-(void)cda_fetchImageWithAsset:(CDAAsset*)asset
                           URL:(NSURL*)URL
              placeholderImage:(UIImage *)placeholderImage {
    if (placeholderImage) {
        self.image = placeholderImage;
    }

    if (!URL) {
        return;
    }
    
    [self showActivityIndicatorIfNeeded];
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:URL]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               [self hideActivityIndicator];
                               
                               if (!data) {
                                   NSLog(@"Error while request '%@': %@", response.URL, error);
                                   return;
                               }
                               
                               self.image = [UIImage imageWithData:data];
                               [self cda_handleCachingForAsset:asset];
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
                        size:(CGSize)size
            placeholderImage:(UIImage *)placeholderImage {
    [self cda_validateAsset:asset];
    
    if (self.offlineCaching_cda) {
        NSString* cacheFilePath = CDACacheFileNameForResource(asset);
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath]) {
            UIImage* cachedImage = [UIImage imageWithContentsOfFile:cacheFilePath];
            
            NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:cacheFilePath error:nil];
            NSDate *date = [attributes fileModificationDate];

            if (![asset updatedAfterDate:date]
                && size.width <= cachedImage.size.width
                && size.height <= cachedImage.size.height) {

                [asset.client fetchAssetWithIdentifier:asset.identifier
                                               success:^(CDAResponse *response, CDAAsset *asset) {
                                                   if ([asset updatedAfterDate:date]) {
                                                       [self cda_fetchImageWithAsset:asset
                                                                                 URL:URL
                                                                    placeholderImage:cachedImage];
                                                   }
                                               } failure:nil];
                
                self.image = cachedImage;
                return;
            }
        }
    }
    
    [self cda_fetchImageWithAsset:asset URL:URL placeholderImage:placeholderImage];
}

-(void)cda_setImageWithAsset:(CDAAsset *)asset {
    [self cda_setImageWithAsset:asset URL:asset.URL size:asset.size placeholderImage:nil];
}

-(void)cda_setImageWithAsset:(CDAAsset *)asset size:(CGSize)size {
    [self cda_setImageWithAsset:asset URL:[asset imageURLWithSize:size] size:size placeholderImage:nil];
}

-(void)cda_setImageWithAsset:(CDAAsset *)asset placeholderImage:(UIImage *)placeholderImage {
    [self cda_setImageWithAsset:asset URL:asset.URL size:asset.size placeholderImage:placeholderImage];
}

-(void)cda_setImageWithAsset:(CDAAsset *)asset
                        size:(CGSize)size
            placeholderImage:(UIImage *)placeholderImage {
    [self cda_setImageWithAsset:asset
                            URL:[asset imageURLWithSize:size]
                           size:size
               placeholderImage:placeholderImage];
}

-(void)cda_setImageWithPersistedAsset:(id<CDAPersistedAsset>)asset
                               client:(CDAClient*)client
                                 size:(CGSize)size
                     placeholderImage:(UIImage *)placeholderImage {
    [self cda_setImageWithAsset:asset ? [CDAAsset assetFromPersistedAsset:asset client:client] : nil
                           size:size
               placeholderImage:placeholderImage];
}

-(void)cda_validateAsset:(CDAAsset *)asset {
    if (asset && !asset.isImage) {
        [NSException raise:NSInvalidArgumentException
                    format:@"Asset %@ is not an image.", asset.identifier];
    }
}

#pragma mark - Activity indicator

-(NSLayoutConstraint*)layoutConstraintsWithItem:(id)firstItem
                                         toItem:(id)secondItem
                                      attribute:(NSLayoutAttribute)attribute
                                       constant:(CGFloat)constant {
    NSLayoutAttribute secondAttribute = (attribute == NSLayoutAttributeWidth || attribute == NSLayoutAttributeHeight) ? NSLayoutAttributeNotAnAttribute : attribute;
    return [NSLayoutConstraint constraintWithItem:firstItem
                                        attribute:attribute
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:secondItem
                                        attribute:secondAttribute
                                       multiplier:1.0
                                         constant:constant];
}

-(void)showActivityIndicatorIfNeeded {
    if (self.progressView_cda) {
        return;
    }
    
    static const CGFloat size = 44.0;
    UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((self.frame.size.width - size) / 2, (self.frame.size.height - size) / 2, size, size)];
    activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    activityView.color = [UIColor blackColor];
    
    [activityView startAnimating];
    [self addSubview:activityView];

    if (CGSizeEqualToSize(self.frame.size, CGSizeZero)) {
        activityView.translatesAutoresizingMaskIntoConstraints = NO;

        [self addConstraint:[self layoutConstraintsWithItem:activityView
                                                     toItem:self
                                                  attribute:NSLayoutAttributeCenterX
                                                   constant:0.0]];

        [self addConstraint:[self layoutConstraintsWithItem:activityView
                                                     toItem:self
                                                  attribute:NSLayoutAttributeCenterY
                                                   constant:0.0]];

        [activityView addConstraint:[self layoutConstraintsWithItem:activityView
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeWidth
                                                           constant:activityView.frame.size.width]];

        [activityView addConstraint:[self layoutConstraintsWithItem:activityView
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeHeight
                                                           constant:activityView.frame.size.height]];
    }
    
    self.progressView_cda = activityView;
    
    [self addObserver:self forKeyPath:@"frame" options:0 context:NULL];
}

-(void)hideActivityIndicator {
    if (!self.progressView_cda) {
        return;
    }
    
    [self.progressView_cda removeFromSuperview];
    self.progressView_cda = nil;
    
    [self removeObserver:self forKeyPath:@"frame"];
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context {
    if (![keyPath isEqualToString:@"frame"]) {
        return;
    }
    
    CGFloat size = self.progressView_cda.frame.size.width;
    self.progressView_cda.frame = CGRectMake((self.frame.size.width - size) / 2,
                                             (self.frame.size.height - size) / 2, size, size);
}

#pragma mark - Properties

-(BOOL)offlineCaching_cda {
    return [objc_getAssociatedObject(self, CDAOfflineCachingKey) boolValue];
}

-(UIActivityIndicatorView *)progressView_cda {
    return objc_getAssociatedObject(self, CDAProgressViewKey);
}

-(void)setOfflineCaching_cda:(BOOL)offlineCaching {
    objc_setAssociatedObject(self, CDAOfflineCachingKey, @(offlineCaching), OBJC_ASSOCIATION_RETAIN);
}

-(void)setProgressView_cda:(UIActivityIndicatorView *)progressView {
    objc_setAssociatedObject(self, CDAProgressViewKey, progressView, OBJC_ASSOCIATION_RETAIN);
}

@end
