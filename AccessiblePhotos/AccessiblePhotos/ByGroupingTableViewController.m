//
//  ByGroupingTableViewController.m
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/08/02.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "ByGroupingTableViewController.h"
#import "SingleCapturedContextViewController.h"
#import "CapturedContextManager.h"

@implementation ByGroupingTableViewController
{
    NSDate *dateId;
}

@synthesize groupingParentNode;

- (void)awakeFromNib
{
    dateId = [NSDate date];

    NSLog(@"########## VC %@ awakeFromNib", dateId);
    [super awakeFromNib];
    
}

- (void)viewDidAppear:(BOOL)animated
{    
    NSLog(@"########## VC %@ viewDidAppear", dateId);
    [super viewDidAppear:animated];

    ///// NOT GONNA WORK SINCE THE INTERMEDIATE NON=LEAF LONE=CHILD NODES HAVE ALREADY BEEN PRUNED AT THIS POINT
    // If the current groupingParentNode is a non-leaf that contains no child nodes,
    // pop out until we either reach the root node or a non-leaf that has more than one child.

    // If the groupingParentNode is nil (possibly due to it having been removed from the grouping tree)
    // and we are not the top view controller, pop ourself off.
    if (self.groupingParentNode == nil && self != self.navigationController.topViewController)
    {
        NSLog(@"##########   VC %@: popping", dateId);
        [self.navigationController popViewControllerAnimated:NO];
    }
//    else
//    // If the current groupingParentNode is a non-leaf that just contains one non-leaf grouping node,
//    // drill in until we either reach a leaf or a non-leaf that has more than one child.
//    if (self.groupingParentNode != nil && self.groupingParentNode.numChildNodes == 1 &&
//        ![self.groupingParentNode childAtIndex:0].isLeafNode)
//    {
//        NSLog(@"##########   VC %@: pushing %@", dateId, [self.groupingParentNode childAtIndex:0].data);
//        [self pushNextViewForTreeNode:[self.groupingParentNode childAtIndex:0] animated:NO];
//    }

//    else
//    {
//        [super viewWillAppear:animated];
//    }
}

//- (void)viewDidAppear:(BOOL)animated
//{
//    NSLog(@"########## VC %@ viewDidAppear", dateId);
//
//    [super viewDidAppear:animated];
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([@"showDetailViewSegue" isEqualToString:segue.identifier])
    {
        if ([sender isKindOfClass:[CapturedContext class]])
        {
            SingleCapturedContextViewController *viewController = segue.destinationViewController;
            viewController.capturedContext = (CapturedContext *)sender;
        }        
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return self.groupingParentNode.numChildNodes;
    }
    
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *GroupingNodeCellIdentifier = @"GroupingNodeCell";
    static NSString *LeafNodeCellIdentifier = @"LeafNodeCell";

    TreeNode *childNode = [self.groupingParentNode childAtIndex:indexPath.row];
    NSString *cellIdentifier = GroupingNodeCellIdentifier;
    if (childNode.isLeafNode)
    {
        cellIdentifier = LeafNodeCellIdentifier;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }

    cell.accessoryType = (childNode.isLeafNode ? UITableViewCellAccessoryDetailDisclosureButton : UITableViewCellAccessoryDisclosureIndicator);
    
    cell.textLabel.text = [childNode.data description];

    if (!childNode.isLeafNode)
    {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d children, %d leaves", childNode.numChildNodes, childNode.numSubtreeLeaves];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TreeNode *node = [self.groupingParentNode childAtIndex:indexPath.row];
    [self pushNextViewForTreeNode:node animated:YES];
}

#pragma mark - Private instance methods

- (void)pushNextViewForTreeNode:(TreeNode *)node animated:(BOOL)animated
{
    if (node.isLeafNode)
    {
        NSLog(@"##########   VC %@: pushing detail view for %@", dateId, node.data);
        [self performSegueWithIdentifier:@"showDetailViewSegue" sender:node.data];
    }
    else
    {
        NSLog(@"##########   VC %@: pushing ByGroupingView for %@", dateId, node.data);
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
        ByGroupingTableViewController *controller = [sb instantiateViewControllerWithIdentifier:@"byGroupingTableViewController"];
        controller.groupingParentNode = node;
        
        [self.navigationController pushViewController:controller animated:animated];
    }
}

@end
