//
//  ByMonthTableViewController.m
//  AccessiblePhotos
//
//  Created by Adams Dustin on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ByMonthTableViewController.h"
#import "CapturedContextManager.h"
#import "CapturedContextDateBasedGrouper.h"

@interface ByMonthTableViewController ()

@end

@implementation ByMonthTableViewController
{
    NSArray *differentMonths;
    NSDateFormatter *yearMonthDateFormatter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"yyyyMMM" options:0 locale:[NSLocale currentLocale]];
    yearMonthDateFormatter = [NSDateFormatter new];
    yearMonthDateFormatter.dateFormat = formatString;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //here, call a method that will return all the unique dates as an array, and assign that to datesArray
    differentMonths = [self getDifferentMonths];
    [self.tableView reloadData];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (!differentMonths.count == 0)
    {
        if ([[segue identifier] isEqualToString:@"ByDateSegue"])
        {
            ByDateTableViewController *byDateViewController = segue.destinationViewController;
            
            NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
            TreeNode *uniqueMonthNode = [differentMonths objectAtIndex:[selectedIndexPath row]];        
            
            byDateViewController.uniqueMonthNode = uniqueMonthNode;
        }
    }
}

- (NSArray *)getDifferentMonths
{
    NSMutableArray *months = [[NSMutableArray alloc] init];

    TreeNode *rootNode = [CapturedContextManager sharedManager].dateBasedGroupingRoot;
    for (TreeNode *yearNode in rootNode.childNodes)
    {
        for (TreeNode *monthNode in yearNode.childNodes)
        {
            [months addObject:monthNode];
        }
    }
    
    return months;
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
    if (differentMonths.count == 0)
    {
        return 1;
    }
    else
    {
        return [differentMonths count];        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (differentMonths.count == 0)
    {
        static NSString *noPhotosIdentifier = @"noPhotosCell";
        //this indicates an empty list, if the list is empty, we will display a cell that says "no photos"
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noPhotosIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noPhotosIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"Photo album empty";
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        TreeNode *monthNode = [differentMonths objectAtIndex:[indexPath row]];
        
        int itemsCount = monthNode.numChildNodes;//counts how many days are in that month
        int totalPhotos = monthNode.numSubtreeLeaves;//counts all the photos in that month
        
        if ([monthNode.data isKindOfClass:[DateGroupingNodeData class]])
        {
            DateGroupingNodeData *info = monthNode.data;

            cell.textLabel.text = [yearMonthDateFormatter stringFromDate:info.groupingTimestamp];

            //the below if statements are just to make sure the right plural and singular is being used when displaying the numbers of days and photos
            if (itemsCount == 1)
            {
                if (totalPhotos == 1)
                {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d day, %d photo", itemsCount, totalPhotos];
                }
                else
                {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d day, %d photos", itemsCount, totalPhotos];
                }
            }
            else
            {
                if (totalPhotos == 1)
                {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d days, %d photo", itemsCount, totalPhotos];
                }
                else
                {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d days, %d photos", itemsCount, totalPhotos];
                }
            }
        }
        
        return cell;        
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!differentMonths.count == 0)
    {
        [self performSegueWithIdentifier:@"ByDateSegue" sender:self];        
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
