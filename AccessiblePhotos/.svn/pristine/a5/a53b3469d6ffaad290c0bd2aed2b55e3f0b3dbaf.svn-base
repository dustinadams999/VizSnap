//
//  AudioTableViewController.m
//  AccessiblePhotos
//
//  Created by Adams Dustin on 7/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AudioTableViewController.h"
#import "CapturedContextManager.h"
#import "CapturedContext.h"
#import "AudioTableCell.h"
#import "SingleCapturedContextViewController.h"


@interface AudioTableViewController ()

@end

@implementation AudioTableViewController
{
    NSArray *ccTimesList;
}

@synthesize filterByDate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - CapturedContextScrollViewController overrides

- (NSArray *)updateCapturedContextList
{
    
    //since we now have the unique date of the cell that was pressed, we will use that to grab all the CapturedContexts from the CapturedContextManager that match that date and put them into an array
    NSMutableArray *filteredCapturedContexts = [NSMutableArray new];
    NSDateComponents *components;
    NSDateComponents *components2;
    for (CapturedContext *capturedContext in [CapturedContextManager sharedManager].capturedContexts)
    {
        components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:capturedContext.timestamp];
        components2 = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:self.filterByDate];
        if (([components day] == [components2 day]) && ([components month] == [components2 month]) && ([components year] == [components2 year]))
        {
            [filteredCapturedContexts addObject:capturedContext];
        }
    }
    
    
    return [self sortKeys:filteredCapturedContexts];
}

- (NSArray *)sortKeys:(NSMutableArray *)array
{
    //our array to sort is allPhotos
    NSMutableArray *arrayToSort = [[NSMutableArray alloc] initWithArray:array];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [arrayToSort sortedArrayUsingDescriptors:sortDescriptors];
    return sortedArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //ccTimesList = [self updateCapturedContextList];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    ccTimesList = [self updateCapturedContextList];
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    return ccTimesList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ccTimesList = [self updateCapturedContextList];
    static NSString *CellIdentifier = @"timeCell";
   
    UINib *audioTableCellLoader = [UINib nibWithNibName:@"AudioTableCell" bundle:nil];
    // In tableView:cellForRowAtIndexPath:
    AudioTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[audioTableCellLoader instantiateWithOwner:self options:nil] objectAtIndex:0];
    }
    
    CapturedContext *context = [ccTimesList objectAtIndex:[indexPath row]];
    cell.capturedContext = context;
    
//    NSDate *date = context.timestamp;
    
    //cell.image.image = context.uiImage;
    
    //cell.timeLabel.text = [NSString stringWithFormat:@"%@", [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterLongStyle]];
    
//    NSDateFormatter *dateFormatter = [NSDateFormatter new];
//    dateFormatter.dateFormat = @"h:mm:ss aa";
//    
//    cell.timestampLabel = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:date]];
//    cell.image.image = context.uiImage;
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowSingleCapturedContextSegue"])
    {
        SingleCapturedContextViewController *singleCapturedContextViewController = segue.destinationViewController;
        
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        CapturedContext *context = [ccTimesList objectAtIndex:[selectedIndexPath row]];        
        
        singleCapturedContextViewController.capturedContext = context;
        //dateScrollViewController.mainTitle = [dateFormatter stringFromDate:filterByDate];
    }
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
    [self performSegueWithIdentifier:@"ShowSingleCapturedContextSegue" sender:self];
}

@end
