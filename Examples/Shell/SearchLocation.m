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
    
    CDAClient* client = [[CDAClient alloc] initWithSpaceKey:@"lzjz8hygvfgu" accessToken:@"0c6ef483524b5e46b3bafda1bf355f38f5f40b4830f7599f790a410860c7c271"];
    [client fetchEntriesMatching:@{ @"fields.location[near]": @[ @23, @42 ],
                                    @"content_type": @"7ocuA1dfoccWqWwWUY4UY" }
                         success:^(CDAResponse *response, CDAArray *array) {
                             NSLog(@"%@", array);
                             [NSApp terminate:nil];
                         } failure:^(CDAResponse *response, NSError *error) {
                             NSLog(@"Error: %@", error);
                             [NSApp terminate:nil];
                         }];
    
    [NSApp run];
    return 0;
}
