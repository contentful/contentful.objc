//
//  CDAAboutUsViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 08/05/14.
//
//

#import "CDAAboutUsViewController.h"

@interface CDAAboutUsViewController ()

@end

#pragma mark -

@implementation CDAAboutUsViewController

-(id)init {
    self = [super init];
    if (self) {
        self.tabBarItem.image = [UIImage imageNamed:@"about"];
        self.title = NSLocalizedString(@"About Us", nil);
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

@end
