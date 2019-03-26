//
//  CapturedContextActionViewController.m
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/08/01.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "CapturedContextActionViewController.h"
#import "CapturedContextActionHeaderView.h"

@interface CapturedContextActionViewController () <CapturedContextActionHeaderViewDelegate>

- (IBAction)saveButtonTapped:(id)sender;
- (IBAction)discardButtonTapped:(id)sender;

@end

@implementation CapturedContextActionViewController
{
    CapturedContextActionHeaderView *headerView;
}

@synthesize capturedContext;
@synthesize groupsToSendTo;
@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];

    UINib *viewNib = [UINib nibWithNibName:@"CapturedContextActionHeaderView" bundle:nil];
    headerView = [[viewNib instantiateWithOwner:self options:nil] objectAtIndex:0];
    headerView.capturedContext = self.capturedContext;
    headerView.delegate = self;
    self.title = @"";
    self.navigationItem.title = @"Preview";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [headerView startAudio];

    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [headerView stopAudio];
}

#pragma mark - IBAction methods

- (void)saveButtonTapped:(id)sender
{
    [self.delegate capturedContextActionViewControllerFinished:self];
}

- (void)discardButtonTapped:(id)sender
{
    [self.delegate capturedContextActionViewControllerDiscard:self];
}

#pragma mark - CapturedContextActionHeaderViewDelegate

- (void)capturedContextActionHeaderViewTagToSendLater:(CapturedContextActionHeaderView *)sender
{
    [self.delegate capturedContextActionViewControllerTagToSendLater:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return headerView;
    }
    return [super tableView:tableView viewForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return headerView.bounds.size.height;
    }
    return [super tableView:tableView heightForHeaderInSection:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0)
    {
        return self.groupsToSendTo.count;
    }
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"groupNameCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Send to %@", [self.groupsToSendTo objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self.delegate capturedContextActionViewController:self sendToGroup:[self.groupsToSendTo objectAtIndex:indexPath.row] atIndex:indexPath.row];
}

@end
