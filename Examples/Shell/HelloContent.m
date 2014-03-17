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
    
    CDAClient* client = [CDAClient new];
    [client fetchEntryWithIdentifier:@"nyancat"
                             success:^(CDAResponse *response, CDAEntry *entry) {
                                 NSLog(@"%@", entry.fields);
                                 [NSApp terminate:nil];
                             }
                             failure:^(CDAResponse *response, NSError *error) {
                                 NSLog(@"%@", error);
                                 [NSApp terminate:nil];
                             }];
    
    [NSApp run];
    return 0;
}
