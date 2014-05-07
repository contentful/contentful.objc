//
//  CDATutorialController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 07/05/14.
//
//

#import "CDATutorialController.h"

@interface CDATutorialController () <UIScrollViewDelegate>

@property (nonatomic) UIScrollView* scrollView;

@end

#pragma mark -

@implementation CDATutorialController

- (BOOL)atEndOfScrollView {
    CGFloat position = self.scrollView.contentOffset.x + self.scrollView.bounds.size.width;
    position -= self.scrollView.contentInset.right;
    
    return position > self.scrollView.contentSize.width;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    [self.view addSubview:self.scrollView];
    
    UILabel* firstPage = [[UILabel alloc] initWithFrame:self.view.bounds];
    firstPage.numberOfLines = 0;
    firstPage.text = @"Lorem ipsum dolor sit amet, consectetur adipisicing...";
    firstPage.textAlignment = NSTextAlignmentCenter;
    [self.scrollView addSubview:firstPage];
    
    UILabel* secondPage = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0.0,
                                                                    firstPage.frame.size.width,
                                                                    firstPage.frame.size.height)];
    secondPage.numberOfLines = 0;
    secondPage.text = @"Lorem ipsum dolor sit amet, consectetur adipisicing...";
    secondPage.textAlignment = NSTextAlignmentCenter;
    [self.scrollView addSubview:secondPage];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * 2,
                                             self.scrollView.frame.size.height);
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self atEndOfScrollView]) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
