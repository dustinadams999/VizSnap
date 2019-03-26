//
//  SettingsViewController.m
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/07/24.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "SettingsViewController.h"
#import "Settings.h"
#import "UserManager.h"
#import "LoginViewController.h"
#import "ValueSelectionViewController.h"

@interface SettingsViewController () <LoginViewControllerDelegate, ValueSelectionViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UILabel *logInOutLabel;
@property (nonatomic, weak) IBOutlet UISwitch *alwaysStartInCameraViewSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *useCameraGesturesSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *saveLocationInfoSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *saveCompassInfoSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *faceDetectionEnabledSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *requestSendingEnabledSwitch;
@property (nonatomic, weak) IBOutlet UITableViewCell *maxAmbientAudioRecordingDurationCell;

- (IBAction)alwaysStartInCameraViewChanged:(id)sender;
- (IBAction)useCameraGesturesChanged:(id)sender;
- (IBAction)saveLocationInfoChanged:(id)sender;
- (IBAction)saveCompassInfoChanged:(id)sender;
- (IBAction)faceDetectionEnabledChanged:(id)sender;
- (IBAction)requestSendingEnabledChanged:(id)sender;

@end

@implementation SettingsViewController
{
    UITableViewCell *segueCell;
}

@synthesize logInOutLabel;
@synthesize alwaysStartInCameraViewSwitch;
@synthesize useCameraGesturesSwitch;
@synthesize saveLocationInfoSwitch;
@synthesize saveCompassInfoSwitch;
@synthesize faceDetectionEnabledSwitch;
@synthesize requestSendingEnabledSwitch;
@synthesize maxAmbientAudioRecordingDurationCell;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
    [self updateSettingsValues];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([@"showLoginDialogSegue" isEqualToString:segue.identifier])
    {
        LoginViewController *loginViewController = segue.destinationViewController;
        loginViewController.delegate = self;
    }
    else if ([@"chooseMaxAmbientAudioRecordingDurationSegue" isEqualToString:segue.identifier])
    {
        segueCell = sender;
        ValueSelectionViewController *controller = segue.destinationViewController;
        controller.valueSuffix = @" seconds";
        
        NSArray *values = [NSArray arrayWithObjects:
                           [NSNumber numberWithInt:5],
                           [NSNumber numberWithInt:10],
                           [NSNumber numberWithInt:20],
                           [NSNumber numberWithInt:30],
                           [NSNumber numberWithInt:60],
                           nil];
        controller.title = ((UITableViewCell *)sender).textLabel.text;
        controller.values = values;
        controller.selectedValue = [NSNumber numberWithDouble:[Settings sharedInstance].maxAmbientAudioRecordingDuration];
        controller.message = @"Select the maximum duration for the ambient sound recording.";
        controller.delegate = self;
    }
}

#pragma mark - Private instance methods

- (void)updateSettingsValues
{
    self.alwaysStartInCameraViewSwitch.on = [Settings sharedInstance].alwaysStartInCameraView;
    self.useCameraGesturesSwitch.on = [Settings sharedInstance].useCameraGestures;
    self.saveLocationInfoSwitch.on = [Settings sharedInstance].saveLocationInfo;
    self.saveCompassInfoSwitch.on = [Settings sharedInstance].saveCompassInfo;
    self.faceDetectionEnabledSwitch.on = [Settings sharedInstance].faceDetectionEnabled;
    self.requestSendingEnabledSwitch.on = [Settings sharedInstance].requestSendingEnabled;
    [self.maxAmbientAudioRecordingDurationCell.detailTextLabel setText:[NSString stringWithFormat:@"%.0f sec", [Settings sharedInstance].maxAmbientAudioRecordingDuration]];
    
    [self.tableView reloadData];
}

#pragma mark - IBAction methods

- (IBAction)alwaysStartInCameraViewChanged:(id)sender
{
    [Settings sharedInstance].alwaysStartInCameraView = self.alwaysStartInCameraViewSwitch.isOn;
    [[Settings sharedInstance] saveSettings];
}

- (void)useCameraGesturesChanged:(id)sender
{
    [Settings sharedInstance].useCameraGestures = self.useCameraGesturesSwitch.isOn;
    [[Settings sharedInstance] saveSettings];
}

- (void)saveLocationInfoChanged:(id)sender
{
    [Settings sharedInstance].saveLocationInfo = self.saveLocationInfoSwitch.isOn;
    [[Settings sharedInstance] saveSettings];
}

- (void)saveCompassInfoChanged:(id)sender
{
    [Settings sharedInstance].saveCompassInfo = self.saveCompassInfoSwitch.isOn;
    [[Settings sharedInstance] saveSettings];
}

- (void)faceDetectionEnabledChanged:(id)sender
{
    [Settings sharedInstance].faceDetectionEnabled = self.faceDetectionEnabledSwitch.isOn;
    [[Settings sharedInstance] saveSettings];
}

- (void)requestSendingEnabledChanged:(id)sender
{
    [Settings sharedInstance].requestSendingEnabled = self.requestSendingEnabledSwitch.isOn;
    [[Settings sharedInstance] saveSettings];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = [super tableView:tableView titleForHeaderInSection:section];
    
    if (section == 0)
    {
        if ([UserManager sharedManager].currentUser == nil)
        {
            title = @"Using without logging in";
            self.logInOutLabel.text = @"Log in";
        }
        else
        {
            title = [NSString stringWithFormat:@"Logged in as: %@", [UserManager sharedManager].currentUser.userId];
            self.logInOutLabel.text = @"Logout";
        }
    }
    
    return title;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if ([UserManager sharedManager].currentUser == nil)
        {
            // User has been using without logging in, and now
            // wants to log in
            [Settings sharedInstance].useWithoutLoggingIn = NO;
            [[Settings sharedInstance] saveSettings];
        }
        else
        {
            [[UserManager sharedManager] logoutCurrentUser];
        }
        
        [self performSegueWithIdentifier:@"showLoginDialogSegue" sender:self];
    }
    else if (indexPath.section == 3 && indexPath.row == 0)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - LoginViewControllerDelegate

- (void)loginViewController:(LoginViewController *)controller loggedInUser:(User *)user
{
    [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)loginViewControllerUseWithoutLoggingIn:(LoginViewController *)controller
{
    [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ValueSelectionViewControllerDelegate

- (void)valueSelectionViewController:(ValueSelectionViewController *)controller valueSelected:(id)selectedValue atIndex:(int)selectedValueIndex
{
    if (segueCell == self.maxAmbientAudioRecordingDurationCell)
    {
        [Settings sharedInstance].maxAmbientAudioRecordingDuration = [selectedValue doubleValue];
        [[Settings sharedInstance] saveSettings];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
