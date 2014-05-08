//
//  CDAAssetPreviewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 05/05/14.
//
//

#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>

#import "CDAAssetPreviewController.h"

extern NSString* CDACacheFileNameForResource(CDAResource* resource);

@interface CDAAssetPreviewItem : NSObject <QLPreviewItem>

@property (nonatomic) NSString* title;
@property (nonatomic) NSURL* url;

@end

#pragma mark -

@implementation CDAAssetPreviewItem

-(id)initWithTitle:(NSString*)title URL:(NSURL*)url {
    self = [super init];
    if (self) {
        self.title = title;
        self.url = url;
    }
    return self;
}

-(NSString *)previewItemTitle {
    return self.title;
}

-(NSURL *)previewItemURL {
    return self.url;
}

@end

#pragma mark -

@interface CDAAssetPreviewController () <QLPreviewControllerDataSource>

@property (nonatomic) CDAAsset* asset;
@property (nonatomic, readonly) NSURL* localURL;

@end

#pragma mark -

@implementation CDAAssetPreviewController

+(BOOL)shouldHandleAsset:(CDAAsset*)asset {
    // Limit to files < 1MB
    if ([asset.fields[@"file"][@"details"][@"size"] integerValue] > 1000000) {
        return NO;
    }
    
    return YES;
}

#pragma mark -

-(void)finishLoading {
    [self reloadData];
    
    if (self.previewDelegate) {
        [self.previewDelegate assetPreviewControllerDidLoadAssetPreview:self];
    }
}

-(id)initWithAsset:(CDAAsset*)asset {
    self = [super init];
    if (self) {
        self.asset = asset;
        self.dataSource = self;
    }
    return self;
}

-(NSURL *)localURL {
    return [NSURL fileURLWithPath:CDACacheFileNameForResource(self.asset)];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.localURL checkResourceIsReachableAndReturnError:nil]) {
        [self finishLoading];
        return;
    }
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:self.asset.URL]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *connectionError) {
                               if (data) {
                                   [data writeToURL:self.localURL atomically:YES];
                                   
                                   [self finishLoading];
                               }
                           }];
}

#pragma mark - QLPreviewControllerDataSource

-(NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return [self.localURL checkResourceIsReachableAndReturnError:nil] ? 1 : 0;
}

-(id<QLPreviewItem>)previewController:(QLPreviewController *)controller
                   previewItemAtIndex:(NSInteger)index {
    return [[CDAAssetPreviewItem alloc] initWithTitle:self.asset.fields[@"title"] URL:self.localURL];
}

@end
