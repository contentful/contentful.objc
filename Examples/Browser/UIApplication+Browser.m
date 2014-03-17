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

-(void)setClient:(CDAClient *)client {
    CDAAppDelegate* delegate = self.delegate;
    delegate.client = client;
}

@end
