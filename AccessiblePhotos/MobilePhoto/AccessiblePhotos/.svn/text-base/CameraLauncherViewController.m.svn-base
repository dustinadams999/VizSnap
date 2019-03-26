//
//  CameraLauncherViewController.m
//  NewAppPrototype
//
//  Created by 原田 丞 on 12/07/13.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "CameraLauncherViewController.h"
#import "ContextCaptureViewController.h"
#import "CapturedContext.h"
#import "CapturedContextManager.h"
#import "WebRequestManager.h"
#import "UserManager.h"
#import "LoginViewController.h"

@interface CameraLauncherViewController () <ContextCaptureViewControllerDelegate, LoginViewControllerDelegate>

@end

@implementation CameraLauncherViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Check to see if we need to show the login screen.
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"useWithoutLoggingIn"] boolValue] == NO &&
        [UserManager sharedManager].currentUser == nil)
    {
        [self performSegueWithIdentifier:@"showLoginSegue" sender:self];
    }
    else
    {
        [self performSegueWithIdentifier:@"startCameraSegue" sender:self];
        
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"tap once on the screen to enable gesture mode, and you should hear \"camera ready.\" To capture a photo, tap once. To save photo to album, swipe down. To tag photo for sending later, swipe up. To cancel swipe left.");
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([@"startCameraSegue" isEqualToString:segue.identifier])
    {
        ContextCaptureViewController *imageCaptureViewController = segue.destinationViewController;
        imageCaptureViewController.delegate = self;
    }
    else if ([@"showLoginSegue" isEqualToString:segue.identifier])
    {
        LoginViewController *loginViewController = segue.destinationViewController;
        loginViewController.delegate = self;
    }
}

#pragma mark - LoginViewControllerDelegate

- (void)loginViewController:(LoginViewController *)controller loggedInUser:(User *)user
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)loginViewControllerUseWithoutLoggingIn:(LoginViewController *)controller
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - ContextCaptureViewControllerDelegate

- (void)contextCaptureViewControllerFinished:(ContextCaptureViewController *)sender
{
    self.tabBarController.selectedIndex = 1;

    [self dismissViewControllerAnimated:NO completion:^{
    }];
}

@end
