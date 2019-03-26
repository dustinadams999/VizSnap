//
//  NewAppPrototypeAppDelegate.m
//  NewAppPrototype
//
//  Created by Adams Dustin on 12/07/04.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
//#import "UserManager.h"
#import "Settings.h"
#import <AudioToolbox/AudioToolbox.h>
#import "ByGroupingTableViewController.h"
#import "CapturedContextManager.h"
#import <AVFoundation/AVFoundation.h>
#import "AudioSessionManager.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //////////////////////////////////////////////
    // Set up the audio session parameters.
    [AudioSessionManager sharedManager].currentMode = kAudioSessionModeNoAudio;
    
    
    if ([self.window.rootViewController isKindOfClass:[UITabBarController class]])
    {
        UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;

        // Get 
        UIViewController *viewController = [tabBarController.viewControllers objectAtIndex:1];
        if ([viewController isKindOfClass:[UINavigationController class]])
        {
            UIViewController *topViewController = ((UINavigationController *)viewController).topViewController;
            if ([topViewController isKindOfClass:[ByGroupingTableViewController class]])
            {
                ByGroupingTableViewController *byGroupingTableViewController = (ByGroupingTableViewController *)topViewController;
                byGroupingTableViewController.groupingParentNode = [CapturedContextManager sharedManager].dateBasedGroupingRoot;
            }
        }
        
        
        
//        UIViewController *viewController = [tabBarController.viewControllers objectAtIndex:1];
//        if ([viewController isKindOfClass:[UINavigationController class]])
//        {
//            UIViewController *topViewController = ((UINavigationController *)viewController).topViewController;
//            if ([topViewController isKindOfClass:[ByGroupingTableViewController class]])
//            {
//                ByGroupingTableViewController *byGroupingTableViewController = (ByGroupingTableViewController *)topViewController;
//                byGroupingTableViewController.groupingParentNode = [CapturedContextManager sharedManager].dateBasedGroupingRoot;
//            }
//        }
    }
    
    
    //BELOW IF STATEMENT COMMENTED OUT BY DUSTIN 03/16/2015. This block of code is causing the tab to disappear
    
    // Disable certain tabs if in standard mode.
    /*if ([Settings sharedInstance].interfaceType == kInterfaceTypeStandard)
    {
        if ([self.window.rootViewController isKindOfClass:[UITabBarController class]])
        {
            UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
            NSMutableArray *tabs = [tabBarController.viewControllers mutableCopy];
            [tabs removeObjectAtIndex:2];
            tabBarController.viewControllers = tabs;
        }
    }*/
    
    if ([Settings sharedInstance].alwaysStartInCameraView == NO)
    {
        if ([self.window.rootViewController isKindOfClass:[UITabBarController class]])
        {
            UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
            tabBarController.selectedIndex = 1;
        }
    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
    /*
    //setup for push notifications
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    //end push notifications
     */
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"AppDelegate: applicationWillResignActive called");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

    // Post a notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.ibm.research.tokyo.AccessiblePhotos.ApplicationWillResignActive" object:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"AppDelegate: applicationDidEnterBackground called");
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    // Post a notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.ibm.research.tokyo.AccessiblePhotos.ApplicationDidEnterBackground" object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"AppDelegate: applicationWillEnterForeground called");
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

    if ([Settings sharedInstance].alwaysStartInCameraView == YES)
    {
        if ([self.window.rootViewController isKindOfClass:[UITabBarController class]])
        {
            UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
            tabBarController.selectedIndex = 0;
        }
    }

    // Post a notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.ibm.research.tokyo.AccessiblePhotos.ApplicationWillEnterForeground" object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"AppDelegate: applicationDidBecomeActive called");

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    // Post a notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.ibm.research.tokyo.AccessiblePhotos.ApplicationDidBecomeActive" object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"AppDelegate: applicationWillTerminate called");

    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Post a notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.ibm.research.tokyo.AccessiblePhotos.ApplicationWillTerminate" object:nil];
}

@end
