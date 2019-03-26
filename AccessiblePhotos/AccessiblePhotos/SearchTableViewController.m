//
//  SearchTableViewController.m
//  AccessiblePhotos
//
//  Created by Dustin Adams on 2/20/14.
//
//

#import "SearchTableViewController.h"
#import "CapturedContextDateBasedGrouper.h"
#import "CapturedContextDetailScrollViewController.h"
#import "AudioPreviewViewController.h"
#import "AudioTableCell.h"

@interface SearchTableViewController ()
{
    NSMutableArray *searchResults;
    NSArray *allCapturedContexts;
}
@end

@implementation SearchTableViewController
@synthesize uniqueMonthNode;
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
    allCapturedContexts = [[NSMutableArray alloc] initWithArray:[CapturedContextManager sharedManager].capturedContexts];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //uniqueMonthNode is not particularly useful for us since we are not looking for a particular month, rather a group 
    
    if ([[segue identifier] isEqualToString:@"ViewDetailSegue"])
    {
        SingleCapturedContextViewController *singleCapturedContextViewController = segue.destinationViewController;
        
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        CapturedContext *context = [searchResults objectAtIndex:[selectedIndexPath row]];
        
        singleCapturedContextViewController.capturedContext = context;
        //dateScrollViewController.mainTitle = [dateFormatter stringFromDate:filterByDate];
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [allCapturedContexts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Configure the cell...
    
    static NSString *CellIdentifier = @"timeCell";
    
    UINib *audioTableCellLoader = [UINib nibWithNibName:@"AudioTableCell" bundle:nil];
    // In tableView:cellForRowAtIndexPath:
    AudioTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[audioTableCellLoader instantiateWithOwner:self options:nil] objectAtIndex:0];
    }
    
    //THE FACT WE'RE CALLING FROM THE ALL CAPTURED CONTEXTS ARRAY MIGHT BE WRONG, I'M NOT SURE WE'LL FIND OUT ONCE WE IMPLEMENT THE SEARCH FUNCTION
    
    CapturedContext *context = [allCapturedContexts objectAtIndex:[indexPath row]];
    cell.capturedContext = context;
    
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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
