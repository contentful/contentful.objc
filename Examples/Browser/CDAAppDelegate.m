//
//  CDAAppDelegate.m
//  Browser
//
//  Created by Boris Bügling on 14/03/14.
//
//

#import "CDAAppDelegate.h"
#import "CDASpaceSelectionViewController.h"

@implementation CDAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [CDASpaceSelectionViewController new];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
