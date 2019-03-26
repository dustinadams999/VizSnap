//
//  ByMonthTableViewController.m
//  AccessiblePhotos
//
//  Created by Adams Dustin on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ByMonthTableViewController.h"



@interface ByMonthTableViewController ()

@end

@implementation ByMonthTableViewController

@synthesize differentMonths;

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
    
    differentMonths = [self getDifferentMonths];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ByDateSegue"])
    {
        ByDateTableViewController *byDateViewController = segue.destinationViewController;
        
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        NSDate *uniqueMonth = [differentMonths objectAtIndex:[selectedIndexPath row]];        
        
        byDateViewController.uniqueMonth = uniqueMonth;
        //dateScrollViewController.mainTitle = [dateFormatter stringFromDate:filterByDate];
    }
}

- (NSArray *)getDifferentMonths
{
    BOOL isInMonths;
    NSMutableArray *months = [[NSMutableArray alloc] init];
    NSDateComponents *components;
    NSDateComponents *components2;
    
    for (CapturedContext *capturedContext in [CapturedContextManager sharedManager].capturedContexts)
    {
        isInMonths = FALSE;
        //once we have that captured context's date, find out whether it's already been encountered or not
        components = [[NSCalendar currentCalendar] components:NSMonthCalendarUnit fromDate:capturedContext.timestamp];
        if (months.count == 0)
        {
            //array is empty, add the first date to the array
            [months addObject:capturedContext.timestamp];        
        }
        else
        {
            //go through each item in the keysArray to determine whether timestampString is already a date in one of the capturedContext objects
            for (NSDate *dummyDate in months)
            {
                components2 = [[NSCalendar currentCalendar] components:NSMonthCalendarUnit fromDate:dummyDate];
                if ([components month] == [components2 month])
                {
                    isInMonths = TRUE;
                }
            }
            if (!isInMonths)
            {
                [months addObject:capturedContext.timestamp];  
            }
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
    return [differentMonths count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        //        cell = [[MenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Configure the cell...
    
    //    cell.textLabel.text = [dateFormatter stringFromDate:[uniqueDates objectAtIndex:[indexPath row]]];

    NSDate *date = [differentMonths objectAtIndex:[indexPath row]];

    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSMonthCalendarUnit fromDate:date]; // Get necessary date components
    
    int monthInt = [components month];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];

    NSDateComponents *components1;
    NSDateComponents *components2;
    NSDateComponents *components3;
    components2 = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[differentMonths objectAtIndex:[indexPath row]]];
    BOOL isThere;
    NSMutableArray *dates = [[NSMutableArray alloc] init];
    for (CapturedContext *capturedContext in [CapturedContextManager sharedManager].capturedContexts)
    {
        //once we have that captured context's date, find out whether it's already been encountered or not
        components1 = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:capturedContext.timestamp];
        //Only add dates that fall into our uniqueMonth
        isThere = FALSE;
        //once we have that captured context's date, find out whether it's already been encountered or not
        if (dates == 0)
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
                if (([components1 day] == [components3 day]) && ([components1 month] == [components3 month]) && ([components1 year] == [components3 year])){
                    isThere = TRUE;
                }
            }
            if (!isThere)
            {
                [dates addObject:capturedContext.timestamp];  
            }
        }            
    }

    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)", [[df monthSymbols] objectAtIndex:(monthInt-1)], dates.count];
    
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
    [self performSegueWithIdentifier:@"ByDateSegue" sender:self];
}

@end
