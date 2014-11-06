//
//  CDAConfiguration.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import "CDAConfiguration+Private.h"

@interface CDAConfiguration ()

@property (nonatomic) BOOL usesManagementAPI;

@end

#pragma mark -

@implementation CDAConfiguration

+(instancetype)defaultConfiguration {
    CDAConfiguration* configuration = [CDAConfiguration new];
    configuration.previewMode = NO;
    configuration.rateLimiting = NO;
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
        self.server = @"preview.contentful.com";
    }
}

@end
