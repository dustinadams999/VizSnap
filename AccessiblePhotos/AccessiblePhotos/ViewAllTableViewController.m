//
//  ViewAllTableViewController.m
//  AccessiblePhotos
//
//  Created by Adams Dustin on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewAllTableViewController.h"
#import "AudioTableCell.h"

@interface ViewAllTableViewController ()
{
    NSArray *allPhotos;
}
@end

@implementation ViewAllTableViewController

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
    allPhotos = [self sortKeys];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    allPhotos = [self sortKeys];
    [self.tableView reloadData];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

/*
- (NSArray *)getAllPhotos
{
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    for (CapturedContext *capturedContext in [CapturedContextManager sharedManager].capturedContexts)
    {
        [photos addObject:capturedContext];
    }
    photos = [self sortKeys];
    return photos;
}*/

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ViewDetailSegue"])
    {
        SingleCapturedContextViewController *singleCapturedContextViewController = segue.destinationViewController;
        
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        CapturedContext *context = [allPhotos objectAtIndex:[selectedIndexPath row]];        
        
        singleCapturedContextViewController.capturedContext = context;
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
    return [allPhotos count];
}

- (NSArray *)sortKeys
{
    //our array to sort is allPhotos
    NSMutableArray *arrayToSort = [[NSMutableArray alloc] initWithArray:[CapturedContextManager sharedManager].capturedContexts];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [arrayToSort sortedArrayUsingDescriptors:sortDescriptors];
    return sortedArray;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*static NSString *CellIdentifier = @"timeCell";
    AudioTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        //        cell = [[MenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell = [[AudioTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    // Configure the cell...
    
    CapturedContext *context = [allPhotos objectAtIndex:[indexPath row]];
    cell.capturedContext = context;
    
    //NSDate *date = context.timestamp;
    
    cell.textLabel.text = [NSString stringWithFormat:@"Photo: %d", [indexPath row]];
    
    return cell;*/
    
    allPhotos = [self sortKeys];
    static NSString *CellIdentifier = @"timeCell";
    
    UINib *audioTableCellLoader = [UINib nibWithNibName:@"AudioTableCell" bundle:nil];
    // In tableView:cellForRowAtIndexPath:
    AudioTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[audioTableCellLoader instantiateWithOwner:self options:nil] objectAtIndex:0];
    }
    
    CapturedContext *context = [allPhotos objectAtIndex:[indexPath row]];
    cell.capturedContext = context;
    
//    NSDate *date = context.timestamp;
    
    //cell.image.image = context.uiImage;
    
    //cell.timeLabel.text = [NSString stringWithFormat:@"%@", [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterLongStyle]];
//    NSDateFormatter *dateFormatter = [NSDateFormatter new];
//    dateFormatter.dateFormat = @"h:mm:ss aa, MMMM dd, YYYY";
//    
//    cell.timestampLabel = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:date]];
//    cell.image.image = context.uiImage;
    
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
    [self performSegueWithIdentifier:@"ViewDetailSegue" sender:self];
}

@end
