//
//  UIApplication+Browser.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 14/03/14.
//
//

#import "CDAAppDelegate.h"
#import "UIApplication+Browser.h"

@implementation UIApplication (Browser)

-(CDAClient *)client {
    return ((CDAAppDelegate*)self.delegate).client;
}

-(NSString *)currentLocale {
    return ((CDAAppDelegate*)self.delegate).currentLocale;
}

-(void)setClient:(CDAClient *)client {
    CDAAppDelegate* delegate = self.delegate;
    delegate.client = client;
}

-(void)setCurrentLocale:(NSString *)currentLocale {
    CDAAppDelegate* delegate = self.delegate;
    delegate.currentLocale = currentLocale;
}

@end
