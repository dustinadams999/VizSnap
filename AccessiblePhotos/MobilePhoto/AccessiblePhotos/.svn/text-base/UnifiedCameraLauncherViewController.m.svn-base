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
#import "UserManager.h"
#import "LoginViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Settings.h"

@interface UnifiedCameraLauncherViewController () <ContextCaptureViewControllerDelegate, LoginViewControllerDelegate,
UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation UnifiedCameraLauncherViewController

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
        if ([Settings sharedInstance].useCameraGestures == YES)
        {
            [self performSegueWithIdentifier:@"startGestureBasedCameraSegue" sender:self];
        }
        else
        {
            [self performSegueWithIdentifier:@"startButtonBasedCameraSegue" sender:self];
        }
        
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"tap once on the screen to enable gesture mode, and you should hear \"camera ready.\" To capture a photo, tap once. To save photo to album, swipe down. To tag photo for sending later, swipe up. To cancel swipe left.");
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



#pragma mark - Image saving callback

- (void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        NSLog(@"Error saving image");
    }
    else
    {
        NSLog(@"Successfully saved image");
    }

    [self dismissViewControllerAnimated:NO completion:nil];
}


#pragma mark - UIImagePickerControllerDelegate

// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController:(UIImagePickerController *)picker
 didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *imageToSave;
    
    // Handle a still image capture
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        imageToSave = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        
        // TODO: only save image to camera roll if settings says so
        
        // Save the new image (original or edited) to the Camera Roll
        UIImageWriteToSavedPhotosAlbum(imageToSave, self, @selector(image:finishedSavingWithError:contextInfo:), nil);
    }
    else
    {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

@end
