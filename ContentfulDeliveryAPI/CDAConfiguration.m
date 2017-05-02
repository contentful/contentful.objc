//
//  CDAConfiguration.m
//  ContentfulSDK
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import "CDAConfiguration+Private.h"

NSString* const CDA_DEFAULT_SERVER = @"cdn.contentful.com";
static NSString* const CDA_PREVIEW_SERVER = @"preview.contentful.com";

@interface CDAConfiguration ()

@property (nonatomic) BOOL usesManagementAPI;

@end

#pragma mark -

@implementation CDAConfiguration

+(instancetype)defaultConfiguration {
    CDAConfiguration* configuration = [CDAConfiguration new];
    configuration.filterNonExistingResources = NO;
    configuration.previewMode = NO;
    configuration.rateLimiting = NO;
    configuration.secure = YES;
    configuration.server = CDA_DEFAULT_SERVER;
    return configuration;
}

#pragma mark -

-(void)setPreviewMode:(BOOL)previewMode {
    if (_previewMode == previewMode) {
        return;
    }
    
    _previewMode = previewMode;
    
    if (previewMode) {
        self.server = CDA_PREVIEW_SERVER;
    }
}

@end
