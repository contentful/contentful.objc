//
//  WebViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 25/04/14.
//
//

#import "WebViewController.h"

@interface WebViewController ()

@property (nonatomic, readonly) UIWebView* webView;

@end

#pragma mark -

@implementation WebViewController

@synthesize webView = _webView;

#pragma mark -

-(void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType {
    [self.webView loadData:data
                  MIMEType:MIMEType
          textEncodingName:nil
                   baseURL:nil];
}

-(void)loadURL:(NSURL*)URL {
    [self.webView loadRequest:[NSURLRequest requestWithURL:URL]];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.webView];
}

-(UIWebView *)webView {
    if (_webView) {
        return _webView;
    }
    
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    return _webView;
}

@end
