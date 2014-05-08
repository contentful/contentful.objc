//
//  CDAAboutUsViewController.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 08/05/14.
//
//

#import "CDAAboutUsViewController.h"

@interface CDAAboutUsViewController ()

@end

#pragma mark -

@implementation CDAAboutUsViewController

-(id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"About Us", nil);
    }
    return self;
}

@end
