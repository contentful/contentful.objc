//
//  CDASpaceViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 30/04/14.
//
//

#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>

#import "CDAAboutUsViewController.h"
#import "CDAAssetListViewController.h"
#import "CDAContentTypesViewController.h"
#import "CDASpaceViewController.h"
#import "UIApplication+Browser.h"

@interface CDASpaceViewController () <UIActionSheetDelegate>

@property (nonatomic, readonly) CDAAboutUsViewController* aboutUs;
@property (nonatomic, readonly) CDAResourcesCollectionViewController* assets;
@property (nonatomic, readonly) CDAResourcesViewController* contentTypes;
@property (nonatomic, readonly) UIBarButtonItem* localeButton;
@property (nonatomic, readonly) UIBarButtonItem* logoutButton;

@end

#pragma mark -

@implementation CDASpaceViewController

@synthesize aboutUs = _aboutUs;
@synthesize assets = _assets;
@synthesize contentTypes = _contentTypes;

#pragma mark -

-(CDAAboutUsViewController *)aboutUs {
    if (_aboutUs) {
        return _aboutUs;
    }
    
    _aboutUs = [CDAAboutUsViewController new];
    
    return _aboutUs;
}

-(CDAResourcesCollectionViewController *)assets {
    if (_assets) {
        return _assets;
    }
    
    _assets = [CDAAssetListViewController new];
    _assets.locale = [UIApplication sharedApplication].currentLocale;
    _assets.navigationItem.leftBarButtonItem = self.localeButton;
    _assets.navigationItem.rightBarButtonItem = self.logoutButton;
    
    return _assets;
}

-(UIViewController *)contentTypes {
    if (_contentTypes) {
        return _contentTypes;
    }
    
    _contentTypes = [CDAContentTypesViewController new];
    _contentTypes.client = [UIApplication sharedApplication].client;
    _contentTypes.locale = [UIApplication sharedApplication].currentLocale;
    _contentTypes.navigationItem.leftBarButtonItem = self.localeButton;
    _contentTypes.navigationItem.rightBarButtonItem = self.logoutButton;
    
    [_contentTypes.client fetchSpaceWithSuccess:^(CDAResponse *response, CDASpace *space) {
        [UIApplication sharedApplication].currentLocale = space.defaultLocale;
        _contentTypes.navigationItem.title = space.name;
    } failure:nil];
    
    return _contentTypes;
}

-(UIBarButtonItem*)localeButton {
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"flag"]
                                            style:UIBarButtonItemStyleBordered
                                           target:self
                                           action:@selector(changeLocale)];
}

-(UIBarButtonItem *)logoutButton {
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"logout"]
                                            style:UIBarButtonItemStyleBordered
                                           target:self
                                           action:@selector(logout)];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewControllers = @[ [[UINavigationController alloc] initWithRootViewController:self.contentTypes],
                              [[UINavigationController alloc] initWithRootViewController:self.assets],
                              [[UINavigationController alloc] initWithRootViewController:self.aboutUs]];
}

#pragma mark - Actions

-(void)changeLocale {
    [[UIApplication sharedApplication].client fetchSpaceWithSuccess:^(CDAResponse *response,
                                                                      CDASpace *space) {
        NSArray* locales = [space.locales valueForKey:@"code"];
        
        UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:NSLocalizedString(@"Select locale", nil)
                                      delegate:self
                                      cancelButtonTitle:nil
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:nil];
        
        for (NSString *locale in locales) {
            [actionSheet addButtonWithTitle:locale];
        }
        
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
        actionSheet.cancelButtonIndex = locales.count;
        
        [actionSheet showInView:self.view];
    } failure:nil];
}

-(void)logout {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    [UIApplication sharedApplication].currentLocale = [actionSheet buttonTitleAtIndex:buttonIndex];
    self.assets.locale = [UIApplication sharedApplication].currentLocale;
    self.contentTypes.locale = [UIApplication sharedApplication].currentLocale;
}

@end
