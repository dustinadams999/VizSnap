//
//  NewAppPrototypeAppDelegate.m
//  NewAppPrototype
//
//  Created by Adams Dustin on 12/07/04.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "UserManager.h"
#import "LocationManager.h"
#import "Settings.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSDictionary *appDefaults = [NSDictionary dictionaryWithObject:@"0" forKey:@"interfaceType"];
    
    
    
    // Start the location manager
    [[LocationManager sharedManager] start];
    
    
    NSString *interfaceType = [[NSUserDefaults standardUserDefaults] objectForKey:@"interfaceType"];
    
    if ([@"unified" isEqualToString:interfaceType])
    {
        UIStoryboard *gestureCentricStoryboard = [UIStoryboard storyboardWithName:@"UnifiedStoryboard" bundle:[NSBundle mainBundle]];
        self.window.rootViewController = [gestureCentricStoryboard instantiateInitialViewController];
        
        if ([Settings sharedInstance].alwaysStartInCameraView == NO)
        {
            if ([self.window.rootViewController isKindOfClass:[UITabBarController class]])
            {
                UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
                tabBarController.selectedIndex = 1;
            }
        }
    }
    else if ([@"gestures" isEqualToString:interfaceType])
    {
        UIStoryboard *gestureCentricStoryboard = [UIStoryboard storyboardWithName:@"GestureCentricStoryboard" bundle:[NSBundle mainBundle]];
        self.window.rootViewController = [gestureCentricStoryboard instantiateInitialViewController];
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

    // Post a notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.ibm.research.tokyo.AccessiblePhotos.ApplicationWillResignActive" object:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    [[LocationManager sharedManager] stop];
    
    // Post a notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.ibm.research.tokyo.AccessiblePhotos.ApplicationDidEnterBackground" object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

    if ([Settings sharedInstance].alwaysStartInCameraView == YES)
    {
        if ([self.window.rootViewController isKindOfClass:[UITabBarController class]])
        {
            UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
            tabBarController.selectedIndex = 0;
        }
    }

    [[LocationManager sharedManager] start];

    // Post a notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.ibm.research.tokyo.AccessiblePhotos.ApplicationWillEnterForeground" object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    // Post a notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.ibm.research.tokyo.AccessiblePhotos.ApplicationDidBecomeActive" object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Post a notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.ibm.research.tokyo.AccessiblePhotos.ApplicationWillTerminate" object:nil];
}

@end
