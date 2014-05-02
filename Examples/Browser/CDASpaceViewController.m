//
//  CDASpaceViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 30/04/14.
//
//

#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>

#import "CDAAssetListViewController.h"
#import "CDASpaceViewController.h"
#import "UIApplication+Browser.h"

@interface CDASpaceViewController ()

@property (nonatomic, readonly) CDAResourcesCollectionViewController* assets;
@property (nonatomic, readonly) CDAResourcesViewController* contentTypes;

@end

#pragma mark -

@implementation CDASpaceViewController

@synthesize assets = _assets;
@synthesize contentTypes = _contentTypes;

#pragma mark -

-(CDAResourcesCollectionViewController *)assets {
    if (_assets) {
        return _assets;
    }
    
    _assets = [CDAAssetListViewController new];
    
    return _assets;
}

-(UIViewController *)contentTypes {
    if (_contentTypes) {
        return _contentTypes;
    }
    
    _contentTypes = [[CDAResourcesViewController alloc] initWithCellMapping:@{ @"textLabel.text": @"name" }];
    _contentTypes.client = [UIApplication sharedApplication].client;
    _contentTypes.resourceType = CDAResourceTypeContentType;
    _contentTypes.title = NSLocalizedString(@"Entries", nil);
    
    [_contentTypes.client fetchSpaceWithSuccess:^(CDAResponse *response, CDASpace *space) {
        _contentTypes.navigationItem.title = space.name;
    } failure:nil];
    
    return _contentTypes;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewControllers = @[ [[UINavigationController alloc] initWithRootViewController:self.contentTypes],
                              [[UINavigationController alloc] initWithRootViewController:self.assets] ];
}

@end
