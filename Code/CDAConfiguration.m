//
//  CDAConfiguration.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import "CDAConfiguration.h"

@implementation CDAConfiguration

+(instancetype)defaultConfiguration {
    CDAConfiguration* configuration = [CDAConfiguration new];
    configuration.previewLocale = nil;
    configuration.previewMode = NO;
    configuration.secure = YES;
    configuration.server = @"cdn.contentful.com";
    return configuration;
}

#pragma mark -

-(void)setPreviewMode:(BOOL)previewMode {
    if (_previewMode == previewMode) {
        return;
    }
    
    _previewMode = previewMode;
    
    if (previewMode) {
        self.server = @"api.contentful.com";
    }
}

@end
