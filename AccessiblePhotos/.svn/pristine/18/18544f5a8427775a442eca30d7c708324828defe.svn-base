//
//  LoginViewController.m
//  NewAppPrototype
//
//  Created by 原田 丞 on 12/07/13.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "LoginViewController.h"
#import "UserManager.h"
#import "Settings.h"

@interface LoginViewController ()

@property (nonatomic, weak) IBOutlet UINavigationItem *navigationItem;
@property (nonatomic, weak) IBOutlet UITextField *usernameTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;

- (IBAction)loginButtonTapped:(id)sender;
- (IBAction)useWithoutLoggingInButtonTapped:(id)sender;

@end

@implementation LoginViewController

@synthesize delegate;
@synthesize navigationItem;
@synthesize usernameTextField;
@synthesize passwordTextField;

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.usernameTextField)
    {
        [self.passwordTextField becomeFirstResponder];
        return NO;
    }
    else if (textField == self.passwordTextField)
    {
        [self attemptLogin];
        return NO;
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *trimmedNewString = [[textField.text stringByReplacingCharactersInRange:range withString:string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *trimmedUserIdText = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; 
    NSString *trimmedPasswordText = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; 
    
    if (textField == self.usernameTextField && trimmedNewString.length > 0 && trimmedPasswordText.length > 0)
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else if (textField == self.passwordTextField && trimmedNewString.length > 0 && trimmedUserIdText.length > 0)
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    return YES;
}

#pragma mark - IBAction methods

- (IBAction)loginButtonTapped:(id)sender
{
    [self attemptLogin];
}

- (IBAction)useWithoutLoggingInButtonTapped:(id)sender
{
    [Settings sharedInstance].useWithoutLoggingIn = YES;
    [[Settings sharedInstance] saveSettings];
    // TODO
    if (self.delegate != nil)
    {
        [self.delegate loginViewControllerUseWithoutLoggingIn:self];
    }
}

#pragma mark - Private class methods

- (void)attemptLogin
{
    // TODO
//    [self.delegate loginDialog:self gotUserId:self.userIdTextField.text password:self.passwordTextField.text];
    // try logging in
    [[UserManager sharedManager] authenticateWithUserID:self.usernameTextField.text password:self.passwordTextField.text callback:^(User *user, NSString *errorMessage) {
        if (user == nil)
        {
            [self repromptWithMessage:errorMessage];
        }
        else
        {
            [Settings sharedInstance].useWithoutLoggingIn = NO;
            [[Settings sharedInstance] saveSettings];
            if (self.delegate != nil)
            {
                [self.delegate loginViewController:self loggedInUser:nil];
            }
        }
    }];
}

- (void)repromptWithMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unable to authenticate", @"Login dialog view")
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"Re-enter", @"Login dialog view")
                                          otherButtonTitles:nil];
    [alert show];
    
    [self.passwordTextField becomeFirstResponder];
}

@end
