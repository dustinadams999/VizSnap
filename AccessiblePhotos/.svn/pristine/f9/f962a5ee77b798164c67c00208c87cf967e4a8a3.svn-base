//
//  SimpleCameraLauncherViewController.m
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/07/24.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "UnifiedCameraLauncherViewController.h"
#import "ContextCaptureViewController.h"
#import "CapturedContext.h"
#import "CapturedContextManager.h"
#import "WebRequestManager.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Settings.h"

@interface UnifiedCameraLauncherViewController () <ContextCaptureViewControllerDelegate>

@end

@implementation UnifiedCameraLauncherViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Camera view";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([Settings sharedInstance].useCameraGestures == YES)
    {
        [self performSegueWithIdentifier:@"startGestureBasedCameraSegue" sender:self];
    }
    else
    {
        [self performSegueWithIdentifier:@"startButtonBasedCameraSegue" sender:self];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([@"startButtonBasedCameraSegue" isEqualToString:segue.identifier] ||
        [@"startGestureBasedCameraSegue" isEqualToString:segue.identifier])
    {
        ContextCaptureViewController *imageCaptureViewController = segue.destinationViewController;
        imageCaptureViewController.delegate = self;
    }
}

#pragma mark - ContextCaptureViewControllerDelegate

- (void)contextCaptureViewControllerFinished:(ContextCaptureViewController *)sender
{
    self.tabBarController.selectedIndex = 1;
    [self dismissViewControllerAnimated:NO completion:^{}];
}

@end
