//
//  CDATutorialController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 07/05/14.
//
//

#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>

#import "CDATutorialController.h"
#import "CDATutorialView.h"
#import "UIView+Geometry.h"

@interface CDATutorialController () <UIScrollViewDelegate>

@property (nonatomic) CDAClient* client;
@property (nonatomic) UIScrollView* scrollView;

@end

#pragma mark -

@implementation CDATutorialController

- (BOOL)atEndOfScrollView {
    CGFloat position = self.scrollView.contentOffset.x + self.scrollView.bounds.size.width;
    position -= self.scrollView.contentInset.right;
    
    return position > self.scrollView.contentSize.width;
}

-(id)init {
    self = [super init];
    if (self) {
        self.client = [[CDAClient alloc] initWithSpaceKey:@"tyqxsw7o3ipi"
                                              accessToken:@"5ddd61286e007dd90a78549abd753c96ec7b6d8498e6217fb18328f3842b55b3"];
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    [self.view addSubview:self.scrollView];
    
    [self.client fetchEntryWithIdentifier:@"3dqGz5zXQsK0kmeMCSMgKs"
                                  success:^(CDAResponse *response, CDAEntry *entry) {
                                      CGFloat xCoordinate = 0.0;
                                      NSArray* pages = entry.fields[@"pages"];
                                      
                                      for (CDAEntry* page in pages) {
                                          CDATutorialView* tutorialView = [[CDATutorialView alloc] initWithFrame:self.scrollView.bounds];
                                          tutorialView.x = xCoordinate;
                                          xCoordinate += tutorialView.width;
                                          
                                          [tutorialView.backgroundImageView cda_setImageWithAsset:entry.fields[@"backgroundImage"]];
                                          [tutorialView.imageView cda_setImageWithAsset:page.fields[@"asset"]];
                                          
                                          tutorialView.body.text = page.fields[@"content"];
                                          tutorialView.headline.text = page.fields[@"headline"];
                                          
                                          [self.scrollView addSubview:tutorialView];
                                          
                                          if (xCoordinate < 1.0) {
                                              tutorialView.imageView.userInteractionEnabled = YES;
                                              [tutorialView addGestureRecognizer:[[UIGestureRecognizer alloc] initWithTarget:self action:@selector(playVideo)]];
                                          }
                                      }
                                      
                                      self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * pages.count,
                                                                               self.scrollView.frame.size.height);
                                  } failure:^(CDAResponse *response, NSError *error) {
                                      UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                                                          message:error.localizedDescription
                                                                                         delegate:nil
                                                                                cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                                                otherButtonTitles:nil];
                                      [alertView show];
                                  }];
}

#pragma mark - Actions

-(void)playVideo {
    // TODO: Play video
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self atEndOfScrollView]) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
