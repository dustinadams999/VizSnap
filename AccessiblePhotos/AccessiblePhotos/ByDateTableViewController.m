//
//  Tab1TableViewController.m
//  NewAppPrototype
//
//  Created by Adams Dustin on 12/07/12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ByDateTableViewController.h"
#import "CapturedContextDateBasedGrouper.h"
#import "CapturedContextDetailScrollViewController.h"
#import "AudioPreviewViewController.h"

@implementation ByDateTableViewController
{
    NSDateFormatter *monthDayDateFormatter;
    NSDateFormatter *monthDateFormatter;
}

@synthesize uniqueMonthNode;

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"MMMd" options:0 locale:[NSLocale currentLocale]];
    monthDayDateFormatter = [NSDateFormatter new];
    monthDayDateFormatter.dateFormat = formatString;

    formatString = [NSDateFormatter dateFormatFromTemplate:@"MMM" options:0 locale:[NSLocale currentLocale]];
    monthDateFormatter = [NSDateFormatter new];
    monthDateFormatter.dateFormat = formatString;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.uniqueMonthNode.numChildNodes > 0)
    {
        [self.tableView reloadData];

        if ([uniqueMonthNode.data isKindOfClass:[DateGroupingNodeData class]])
        {
            DateGroupingNodeData *data = uniqueMonthNode.data;
            self.navigationItem.title = [monthDateFormatter stringFromDate:data.groupingTimestamp];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.uniqueMonthNode.numChildNodes == 0)
    {
        [self.navigationController popViewControllerAnimated:NO];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowAudioTableSegue"])
    {
        AudioPreviewViewController *byDayAudioViewController = segue.destinationViewController;
        
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        TreeNode *selectedDayNode = [self.uniqueMonthNode childAtIndex:[selectedIndexPath row]];        
        
        byDayAudioViewController.rootNode = selectedDayNode;
    }
    if ([segue.identifier isEqualToString:@"showCapturedContextDetailScrollViewSegue"])
    {
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        TreeNode *selectedDayNode = [self.uniqueMonthNode childAtIndex:[selectedIndexPath row]];        
        
        CapturedContextDetailScrollViewController *destinationViewController = segue.destinationViewController;
        
        destinationViewController.rootNode = selectedDayNode;
        destinationViewController.focusedPageIndex = 0;
        destinationViewController.titleText = [self.tableView cellForRowAtIndexPath:selectedIndexPath].textLabel.text;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.uniqueMonthNode.numChildNodes;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"dateCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    TreeNode *node = ((TreeNode *)[self.uniqueMonthNode childAtIndex:[indexPath row]]);
    NSDate *timestamp = ((DateGroupingNodeData *)node.data).groupingTimestamp;

    int picCount = node.numSubtreeLeaves;

    cell.textLabel.text = [monthDayDateFormatter stringFromDate:timestamp];
    if (picCount == 1)
    {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photo", picCount];
    }
    else
    {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photos", picCount];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [self performSegueWithIdentifier:@"ShowAudioTableSegue" sender:self];
    [self performSegueWithIdentifier:@"showCapturedContextDetailScrollViewSegue" sender:self];
}

@end
