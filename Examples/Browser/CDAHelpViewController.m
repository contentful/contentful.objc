//
//  CDAHelpViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 13/05/14.
//
//

#import "CDAHelpViewController.h"

@interface CDAHelpViewController ()

@end

#pragma mark -

@implementation CDAHelpViewController

-(id)init {
    self = [super init];
    if (self) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped)];
        self.title = NSLocalizedString(@"Help", nil);
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Actions

-(void)doneTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
