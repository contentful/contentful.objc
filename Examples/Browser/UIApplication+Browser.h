//
//  UIApplication+Browser.h
//  ContentfulSDK
//
//  Created by Boris Bügling on 14/03/14.
//
//

#import <UIKit/UIKit.h>

@class CDAClient;

@interface UIApplication (Browser)

@property (strong, nonatomic) CDAClient *client;
@property (strong, nonatomic) NSString* currentLocale;

@end
