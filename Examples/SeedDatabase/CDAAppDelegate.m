//
//  CDAAppDelegate.m
//  SeedDatabaseExample
//
//  Created by Boris Bügling on 25/04/14.
//
//

#import "CDAAppDelegate.h"
#import "DocumentListViewController.h"

@implementation CDAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UINavigationController alloc]
                                      initWithRootViewController:[DocumentListViewController new]];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
