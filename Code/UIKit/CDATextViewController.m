//
//  CDATextViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 17/03/14.
//
//

#import "CDATextViewController.h"

@interface CDATextViewController ()

@property (nonatomic) UITextView* textView;

@end

#pragma mark -

@implementation CDATextViewController

-(void)setText:(NSString *)text {
    if (_text == text) {
        return;
    }
    
    _text = text;
    self.textView.text = text;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.textView.editable = NO;
    self.textView.font = [UIFont systemFontOfSize:18.0];
    self.textView.text = self.text;
    [self.view addSubview:self.textView];
}

@end
