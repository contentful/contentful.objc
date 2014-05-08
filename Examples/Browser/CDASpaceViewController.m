//
//  CDASpaceViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 30/04/14.
//
//

#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>

#import "CDAAssetListViewController.h"
#import "CDAContentTypesViewController.h"
#import "CDASpaceViewController.h"
#import "UIApplication+Browser.h"

@interface CDASpaceViewController ()

@property (nonatomic, readonly) CDAResourcesCollectionViewController* assets;
@property (nonatomic, readonly) CDAResourcesViewController* contentTypes;
@property (nonatomic, readonly) UIBarButtonItem* logoutButton;

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
    _assets.navigationItem.rightBarButtonItem = self.logoutButton;
    
    return _assets;
}

-(UIViewController *)contentTypes {
    if (_contentTypes) {
        return _contentTypes;
    }
    
    _contentTypes = [CDAContentTypesViewController new];
    _contentTypes.client = [UIApplication sharedApplication].client;
    _contentTypes.navigationItem.rightBarButtonItem = self.logoutButton;
    
    [_contentTypes.client fetchSpaceWithSuccess:^(CDAResponse *response, CDASpace *space) {
        _contentTypes.navigationItem.title = space.name;
    } failure:nil];
    
    return _contentTypes;
}

-(UIBarButtonItem *)logoutButton {
    return [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Logout", nil)
                                            style:UIBarButtonItemStyleBordered
                                           target:self
                                           action:@selector(logout)];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewControllers = @[ [[UINavigationController alloc] initWithRootViewController:self.contentTypes],
                              [[UINavigationController alloc] initWithRootViewController:self.assets] ];
}

#pragma mark - Actions

-(void)logout {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
