//
//  WebViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 25/04/14.
//
//

#import "WebViewController.h"

@interface WebViewController ()

@property (nonatomic) NSData* data;
@property (nonatomic) NSString* MIMEType;

@end

#pragma mark -

@implementation WebViewController

-(void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType {
    self.data = data;
    self.MIMEType = MIMEType;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIWebView* webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:webView];

    NSURL* baseURL = [NSURL URLWithString:@"/"];
    if (baseURL) {
        [webView loadData:self.data MIMEType:self.MIMEType textEncodingName:@"" baseURL:baseURL];
    }
    
    self.data = nil;
    self.MIMEType = nil;
}

@end
