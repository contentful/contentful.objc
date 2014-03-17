//
//  CDAAppDelegate.m
//  Catalog
//
//  Created by Boris Bügling on 17/03/14.
//
//

#import "CDAAppDelegate.h"
#import "CDAExampleSelectionViewController.h"

@implementation CDAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[CDAExampleSelectionViewController new]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
