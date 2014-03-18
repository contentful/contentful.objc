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
    CDAConfiguration* configuration = [CDAConfiguration defaultConfiguration];
    configuration.secure = NO;
    CDAClient* client = [[CDAClient alloc] initWithSpaceKey:@"cfexampleapi"
                                                accessToken:@"b4c0n73n7fu1"
                                              configuration:configuration];
    return 0;
}
