//
//  UFOAppDelegate.m
//  UFO Example
//
//  Created by Boris Bügling on 04/03/14.
//
//

#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>

#import "UFOAppDelegate.h"
#import "UFOMapViewController.h"

@interface UFOAppDelegate ()

@property (nonatomic) CDAClient* client;

@end

#pragma mark -

@implementation UFOAppDelegate

-(BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)options {
    UFOMapViewController* mapViewController = [UFOMapViewController new];
    
    self.client = [[CDAClient alloc] initWithSpaceKey:@"lzjz8hygvfgu" accessToken:@"0c6ef483524b5e46b3bafda1bf355f38f5f40b4830f7599f790a410860c7c271"];
    
    Class ufoSightingClass = NSClassFromString(@"UFOSighting");
    if (ufoSightingClass) {
      [self.client registerClass:ufoSightingClass forContentTypeWithIdentifier:@"7ocuA1dfoccWqWwWUY4UY"];
    }
    
    NSString* cacheFilePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"entries.data"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath]) {
        mapViewController.items = [NSKeyedUnarchiver unarchiveObjectWithFile:cacheFilePath];
    } else {
        [self.client fetchEntriesMatching:@{ @"content_type": @"7ocuA1dfoccWqWwWUY4UY" }
                                  success:^(CDAResponse *response, CDAArray *array) {
                                      [self.client fetchAllItemsFromArray:array
                                                                  success:^(NSArray *items) {
                                                                      mapViewController.items = items;
                                                                      
                                                                      [NSKeyedArchiver archiveRootObject:items toFile:cacheFilePath];
                                                                  } failure:^(CDAResponse *response, NSError *error) {
                                                                      [self showError:error];
                                                                  }];
                                  } failure:^(CDAResponse *response, NSError *error) {
                                      [self showError:error];
                                  }];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UINavigationController alloc]
                                      initWithRootViewController:mapViewController];
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)showError:(NSError*)error {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertView show];
}

@end
