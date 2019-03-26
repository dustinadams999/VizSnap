//
//  NewAppPrototypeViewController.m
//  NewAppPrototype
//
//  Created by Adams Dustin on 12/07/04.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ButtonBasedMainScreenViewController.h"
#import "CapturedContext.h"
#import "CapturedContextManager.h"
#import "WebRequestManager.h"
#import "UserManager.h"
#import "LoginViewController.h"

@interface ButtonBasedMainScreenViewController () <ContextCaptureViewControllerDelegate, LoginViewControllerDelegate>

-(IBAction)deleteFiles:(id)sender;

@end

@implementation ButtonBasedMainScreenViewController

#pragma mark - UIViewController overrides

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"startCameraSegue"])
    {
        ContextCaptureViewController *viewController = segue.destinationViewController;
        viewController.delegate = self;
    }
    else if ([@"showLoginSegue" isEqualToString:segue.identifier])
    {
        LoginViewController *loginViewController = segue.destinationViewController;
        loginViewController.delegate = self;
    }
}

#pragma mark - IBActions

// the below method takes all the files from the documents directory, displays them and deletes them - prevents from too many files building up
- (IBAction)deleteFiles:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete all photos?"
                                                    message:@"Are you sure you want to delete all photos?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Delete all", nil];
    [alert show];
}    

#pragma mark - Callback methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSError *error;
        
        for (CapturedContext *capturedContext in [CapturedContextManager sharedManager].capturedContexts)
        {
            if ([[NSFileManager defaultManager] removeItemAtPath:capturedContext.photoFilePath error:&error] == NO)
            {
                NSLog(@"Error removing photo at %@, error: %@", capturedContext.photoFilePath, [error localizedDescription]);
            }
            if ([[NSFileManager defaultManager] removeItemAtPath:capturedContext.audioFilePath error:&error] == NO)
            {
                NSLog(@"Error removing audio at %@, error: %@", capturedContext.audioFilePath, [error localizedDescription]);
            }
        }
        
        NSLog(@"Deleted all photos.");
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Deleted all photos.");
    }
}

#pragma mark - ContextCaptureViewControllerDelegate

- (void)contextCaptureViewControllerFinished:(ContextCaptureViewController *)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
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

@end