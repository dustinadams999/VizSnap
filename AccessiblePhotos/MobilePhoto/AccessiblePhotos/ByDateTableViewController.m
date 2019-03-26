//
//  Tab1TableViewController.m
//  NewAppPrototype
//
//  Created by Adams Dustin on 12/07/12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ByDateTableViewController.h"
#import "MenuCell.h"
#import "CapturedContext.h"
#import "CapturedContextManager.h"
#import "ByDateCapturedContextScrollViewController.h"
#import "AudioTableViewController.h"

@implementation ByDateTableViewController
{
    NSMutableArray *uniqueDates;
    NSDateFormatter *dateFormatter;
}

@synthesize uniqueMonth;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //here, call a method that will return all the unique dates as an array, and assign that to datesArray
    uniqueDates = [self getUniqueDateKeys];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    uniqueDates = nil;
    dateFormatter = nil;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowAudioTableSegue"])
    {
        AudioTableViewController *dateScrollViewController = segue.destinationViewController;
        
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        NSDate *filterByDate = [uniqueDates objectAtIndex:[selectedIndexPath row]];        

        dateScrollViewController.filterByDate = filterByDate;
        //dateScrollViewController.mainTitle = [dateFormatter stringFromDate:filterByDate];
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
    return [uniqueDates count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"menuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
//        cell = [[MenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    // Configure the cell...
    
//    cell.textLabel.text = [dateFormatter stringFromDate:[uniqueDates objectAtIndex:[indexPath row]]];
    
    int picCount = 0;
    NSDateComponents *components;
    NSDateComponents *components2;
    components2 = [[NSCalendar currentCalendar] components: NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[uniqueDates objectAtIndex:[indexPath row]]];
    for (CapturedContext *capturedContext in [CapturedContextManager sharedManager].capturedContexts)
    {
        components = [[NSCalendar currentCalendar] components: NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:capturedContext.timestamp];
        if (([components day] == [components2 day]) && ([components month] == [components2 month]) && ([components year] == [components2 year]))
        {
            picCount++;
        }
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)", [NSDateFormatter localizedStringFromDate:[uniqueDates objectAtIndex:[indexPath row]] dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle], picCount];

    //cell.dateLabel.text = [dateFormatter stringFromDate:[keysArray objectAtIndex:[indexPath row]]];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */

    [self performSegueWithIdentifier:@"ShowAudioTableSegue" sender:self];
}

#pragma mark - Private class methods

-(NSMutableArray *)getUniqueDateKeys
{
    NSMutableArray *dates = [[NSMutableArray alloc] init];
    NSDateComponents *components;
    NSDateComponents *components2;
    NSDateComponents *components3;
    components2 = [[NSCalendar currentCalendar] components:NSMonthCalendarUnit fromDate:uniqueMonth];//this one is just for our unique month
    BOOL isThere;//this will determine whether the date of the CapturedContext object is unique
    //go through each captured context and get the date
    
    for (CapturedContext *capturedContext in [CapturedContextManager sharedManager].capturedContexts)
    {
        //once we have that captured context's date, find out whether it's already been encountered or not
        components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:capturedContext.timestamp];
        if ([components month] == [components2 month])
        {
            //Only add dates that fall into our uniqueMonth
            isThere = FALSE;
            //once we have that captured context's date, find out whether it's already been encountered or not
            if (dates.count == 0)
            {
                //array is empty, add the first date to the array
                [dates addObject:capturedContext.timestamp];        
            }
            else
            {
                //go through each item in the keysArray to determine whether timestampString is already a date in one of the capturedContext objects
                for (NSDate *dummyContext in dates)
                {
                    components3 = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:dummyContext];
                    if (([components day] == [components3 day]) && ([components month] == [components3 month]) && ([components year] == [components3 year])){
                        isThere = TRUE;
                    }
                }
                if (!isThere)
                {
                    [dates addObject:capturedContext.timestamp];  
                }
            }            
        }
    }
    
    /*
    
    for (CapturedContext *capturedContext in [CapturedContextManager sharedManager].capturedContexts)
    {
        isThere = FALSE;
        //once we have that captured context's date, find out whether it's already been encountered or not
        components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:capturedContext.timestamp];
        if (dates.count == 0)
        {
            //array is empty, add the first date to the array
            [dates addObject:capturedContext.timestamp];        
        }
        else
        {
            //go through each item in the keysArray to determine whether timestampString is already a date in one of the capturedContext objects
            for (NSDate *dummyContext in dates)
            {
                components2 = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:dummyContext];
                if (([components day] == [components2 day]) && ([components month] == [components2 month]) && ([components year] == [components2 year])){
                    isThere = TRUE;
                }
            }
            if (!isThere)
            {
                [dates addObject:capturedContext.timestamp];  
            }
        }
    }*/
    return dates;
}

@end
