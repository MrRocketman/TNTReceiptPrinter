//
//  MNAppDelegate.m
//  TNTReceiptPrinter
//
//  Created by James Adams on 6/6/12.
//  Copyright (c) 2012 Pencil Busters, Inc. All rights reserved.
//

#import "MNAppDelegate.h"
#import "MNDebugViewController.h"
#import "MNCommandsViewController.h"
#import "MNHTMLViewController.h"

@implementation MNAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    UIViewController *viewController1, *viewController2, *viewController3;
    /*if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
    {
        viewController1 = [[MNDebugViewController alloc] initWithNibName:@"MNDebugViewController_iPhone" bundle:nil];
        viewController2 = [[MNCommandsViewController alloc] initWithNibName:@"MNCommandsViewController_iPhone" bundle:nil];
        viewController3 = [[MNHTMLViewController alloc] initWithNibName:@"MNHTMLViewController_iPhone" bundle:nil];
    } 
    else 
    {
        viewController1 = [[MNDebugViewController alloc] initWithNibName:@"MNDebugViewController_iPad" bundle:nil];
        viewController2 = [[MNCommandsViewController alloc] initWithNibName:@"MNCommandsViewController_iPad" bundle:nil];
        viewController3 = [[MNHTMLViewController alloc] initWithNibName:@"MNHTMLViewController_iPad" bundle:nil];
    }*/
    viewController1 = [[MNDebugViewController alloc] initWithNibName:@"MNDebugViewController" bundle:nil];
    viewController2 = [[MNCommandsViewController alloc] initWithNibName:@"MNCommandsViewController" bundle:nil];
    viewController3 = [[MNHTMLViewController alloc] initWithNibName:@"MNHTMLViewController" bundle:nil];
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:viewController1, viewController2, viewController3, nil];
    self.window.rootViewController = self.tabBarController;
    self.tabBarController.selectedIndex = 1;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
