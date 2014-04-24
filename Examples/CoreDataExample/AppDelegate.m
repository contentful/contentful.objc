//
//  AppDelegate.m
//  CoreDataExample
//
//  Created by Boris Bügling on 07/04/14.
//
//

#import "AppDelegate.h"
#import "CatListViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UINavigationController alloc]
                                      initWithRootViewController:[CatListViewController new]];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
