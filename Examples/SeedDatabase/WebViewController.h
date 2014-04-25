//
//  WebViewController.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 25/04/14.
//
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController

-(void)loadData:(NSData*)data MIMEType:(NSString *)MIMEType;
-(void)loadURL:(NSURL*)URL;

@end
