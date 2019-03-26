//
//  GenericViewController.m
//  AccessiblePhotos
//
//  Created by Adams Dustin on 7/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GenericViewController.h"

@interface GenericViewController ()

@end

@implementation GenericViewController
{
    NSMutableArray *capturedContextsSubset;
}

@synthesize byLocation;
@synthesize byMonth;
@synthesize byDate;
@synthesize byTime;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
    self.byLocation = FALSE;
    self.byMonth = FALSE;
    self.byDate = FALSE;
    self.byTime = FALSE;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //Set the subset as the entire CapturedContextManager if none of the flags are set. This means that we are on the view all view
    if ((!byLocation) && (!byMonth) && (!byDate) && (!byTime))
    {
        capturedContextsSubset = [CapturedContextManager sharedManager].capturedContexts;

    }
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
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (byLocation)
    {
        //Initialize cells based on location
    }
    else if (byMonth)
    {
        //Initialize cells based on month
    }
    else if (byDate)
    {
        //Initialize cells based on date
    }
    else if (byTime)
    {
        //Initialize cells based on time
    }
    else
    {
        //initialize every captured context in the captured context manager as a cell
    }
    
    
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
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
    NSMutableArray *newSubset = [[NSMutableArray alloc] init];
    GenericViewController *genericViewController = [[GenericViewController alloc] init];
    if (byLocation)
    {
        //If already by location, then next view will be by time. Instanciate a GenericViewController object, set byTime boolean property  to TRUE and set all the other boolean values to no. Push that view onto the navigation controller
        genericViewController.byTime = TRUE;
    }
    else if (byMonth)
    {
        //If already by month, then the next view will be by date. Instanciate a GenericViewController object, set byDate boolean property to TRUE and set all the other boolean values to no. Push that view onto the navigation controller
        genericViewController.byTime = TRUE;        
    }
    else if (byDate)
    {
        //If already by date, then the next view will be by time. Instanciate a GenericViewController object, set byTime boolean property  to TRUE and set all the other boolean values to no. Push that view onto the navigation controller
        genericViewController.byTime = TRUE;        
    }
    else if (byTime)
    {
        //If already by time, then the next view will be the detailed view. Instanciate a SingleCapturedContextViewController object and segue to that
        genericViewController.byTime = TRUE;        
    }
    else
    {
        //here, we assume we are already in ViewAll view, since all booleans are turned off. Instanciate a SingleCapturedContextViewController object and segue to that
    }
}

@end
