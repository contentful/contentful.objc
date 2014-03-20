#!/usr/bin/env objc-run

/*
podfile-start
platform :osx, '10.9'
pod 'ContentfulDeliveryAPI', :git => 'https://github.com/contentful/contentful.objc.git'
podfile-end
*/

#import <Cocoa/Cocoa.h>
#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>

int main(int argc, const char * argv[]) {
    NSApplicationLoad();
    
    CDAConfiguration* configuration = [CDAConfiguration defaultConfiguration];
    configuration.previewMode = YES;
    CDAClient* client = [[CDAClient alloc] initWithSpaceKey:@"cfexampleapi" accessToken:@"5b5367a9a0cc3ab6ac2d4835bd8893907c61d3bafc7cb8b1f51840686a89fae3" configuration:configuration];
    [client fetchEntriesMatching:@{ @"content_type": @"1t9IbcfdCk6m04uISSsaIK" }
                         success:^(CDAResponse *response, CDAArray* array) {
                             NSLog(@"%@", array);
                             [NSApp terminate:nil];
                         }
                         failure:^(CDAResponse *response, NSError *error) {
                             NSLog(@"%@", error);
                             [NSApp terminate:nil];
                         }];
    
    [NSApp run];
    return 0;
}
