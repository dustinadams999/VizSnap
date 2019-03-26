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

@interface SettingsViewController ()

@property (nonatomic, weak) IBOutlet UISwitch *alwaysStartInCameraViewSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *useCameraGesturesSwitch;

- (IBAction)alwaysStartInCameraViewChanged:(id)sender;
- (IBAction)useCameraGesturesChanged:(id)sender;

@end

@implementation SettingsViewController

@synthesize alwaysStartInCameraViewSwitch;
@synthesize useCameraGesturesSwitch;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.alwaysStartInCameraViewSwitch.on = [Settings sharedInstance].alwaysStartInCameraView;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title;
    
    if (section == 0)
    {
        title = [NSString stringWithFormat:@"Logged in as: %@", [UserManager sharedManager].currentUser.userId];
    }
    
    return title;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        [[UserManager sharedManager] logoutCurrentUser];
        
        // TODO: handle
        // FIX: shouldn't have to rely on the camera tab to show the login screen
        self.tabBarController.selectedIndex = 0;
    }
}

@end
