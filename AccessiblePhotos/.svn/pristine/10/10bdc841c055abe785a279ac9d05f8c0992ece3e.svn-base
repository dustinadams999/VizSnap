//
//  AudioPreviewViewController.m
//  AccessiblePhotos
//
//  Created by Adams Dustin on 7/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AudioPreviewViewController.h"
#import "CapturedContext.h"
#import "CapturedContextManager.h"
#import "AudioTableCell.h"
#import "SingleCapturedContextViewController.h"
#import "CapturedContextDateBasedGrouper.h"
#import <AVFoundation/AVFoundation.h>
#import "CapturedContextDetailScrollViewController.h"

@interface AudioPreviewViewController () <UITableViewDelegate, AudioTableCellDelegate, AVAudioPlayerDelegate, CapturedContextDetailScrollViewControllerDelegate>

@end

@implementation AudioPreviewViewController
{
    NSArray *leafNodes;
    NSArray *daySectionNodes;

    NSDateFormatter *monthDayDateFormatter;
    AVAudioPlayer *audioPlayer;
    
    // FIX: this is bad to have reference directly to a cell...
    // make sure it's cleared before this view controller goes out of scope
    AudioTableCell *currentlyPlayingCell;
}

@synthesize mainTitle;
@synthesize rootNode;

- (void)viewDidLoad
{
    [super viewDidLoad];

    monthDayDateFormatter = [NSDateFormatter new];
    monthDayDateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"MMMd" options:0 locale:[NSLocale currentLocale]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    leafNodes = [self updateCapturedContextList];
    {
        // FIX: this makes ToSend view fail since it's returning all day groupings...
//        daySectionNodes = [self getDayGroupingNodesInSubtree:[CapturedContextManager sharedManager].dateBasedGroupingRoot];
        // VERIFY: does below fix the above?
        daySectionNodes = [self getDayGroupingNodesInSubtree:self.rootNode];

        [self.tableView reloadData];
    }
    
    if (leafNodes.count > 0)
    {
        self.navigationItem.title = [NSString stringWithFormat:@"All %d photos", leafNodes.count];
    }
    else
    {
        self.navigationItem.title = @"All photos";
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (leafNodes.count == 0)
    {
        // FIX: or simply show "no photos"?
        [self.navigationController popViewControllerAnimated:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationItem.title = @"All photos";
    
    if (audioPlayer != nil)
    {
        [audioPlayer stop];
        audioPlayer = nil;
    }
    [self signalAudioFinishedPlayingToCurrentlyPlayingCell];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (!leafNodes.count == 0)
    {    
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        AudioTableCell *selectedCell = (AudioTableCell *)[self.tableView cellForRowAtIndexPath:selectedIndexPath];
        
        if ([segue.identifier isEqualToString:@"showCapturedContextDetailScrollViewSegue"])
        {
            CapturedContextDetailScrollViewController *destinationViewController = segue.destinationViewController;
            destinationViewController.delegate = self;
            destinationViewController.rootNode = self.rootNode;
            destinationViewController.focusedPageIndex = selectedCell.rowIndex;
        }
    }
}

#pragma mark - Private instance methods

- (NSArray *)updateCapturedContextList
{
    //this is overridden in the subclasses
    if (self.rootNode == nil)
    {
        self.rootNode = [CapturedContextManager sharedManager].dateBasedGroupingRoot;
    }
    
    return self.rootNode.leafNodes;
}

- (NSArray *)getDayGroupingNodesInSubtree:(TreeNode *)subtreeRoot
{
    NSMutableArray *dayGroupingNodes = [NSMutableArray new];
    
    for (TreeNode *childNode in subtreeRoot.childNodes)
    {
        if ([childNode.data isKindOfClass:[DateGroupingNodeData class]])
        {
            DateGroupingNodeData *data = childNode.data;
            if (data.groupingLevel == kDateGroupingLevelDay)
            {
                [dayGroupingNodes addObject:childNode];
            }
            else
            {
                NSArray *foundNodes = [self getDayGroupingNodesInSubtree:childNode];
                if (foundNodes.count > 0)
                {
                    [dayGroupingNodes addObjectsFromArray:foundNodes];
                }
            }
        }
    }
    
    return dayGroupingNodes;
}

- (void)signalAudioStoppedToCurrentlyPlayingCell
{
    if (currentlyPlayingCell != nil)
    {
        [currentlyPlayingCell audioStopped];
        currentlyPlayingCell = nil;
    }
}

- (void)signalAudioFinishedPlayingToCurrentlyPlayingCell
{
    if (currentlyPlayingCell != nil)
    {
        [currentlyPlayingCell audioFinishedPlaying];
        currentlyPlayingCell = nil;
    }
}

#pragma mark - AudioTableCellDelegate

- (void)audioTableCell:(AudioTableCell *)sender startPlayingAudioOfCapturedContext:(CapturedContext *)capturedContext
{
    if (audioPlayer != nil)
    {
        [audioPlayer stop];
        audioPlayer = nil;
    }
    [self signalAudioFinishedPlayingToCurrentlyPlayingCell];

    // Below, we get the url of the audio file we'll be playing
    NSError *error;
    
    NSURL *audioFileURL = nil;
    if (capturedContext.memoAudioFileExists == YES)
    {
        audioFileURL = [NSURL fileURLWithPath:capturedContext.memoFilePath];
    }
    else if (capturedContext.ambientAudioFileExists == YES)
    {
        audioFileURL = [NSURL fileURLWithPath:capturedContext.ambientAudioFilePath];
    }
    
    if (audioFileURL != nil)
    {
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileURL error:&error];
        audioPlayer.delegate = self;

        if (error)
        {
            NSLog(@"ERROR: %@", [error localizedDescription]);
        }
        else
        {
            [audioPlayer play];
        }
        currentlyPlayingCell = sender;
    }
    else
    {
        NSLog(@"ERROR: AudioPreviewViewController: NO memo or ambient audio file to play for captured context %@", capturedContext);
    }
}

- (void)audioTableCell:(AudioTableCell *)sender stopPlayingAudioOfCapturedContext:(CapturedContext *)capturedContext
{
    //here, we will stop the audio of the table cell
    if (audioPlayer != nil)
    {
        [audioPlayer stop];
        audioPlayer = nil;
    }
    [self signalAudioStoppedToCurrentlyPlayingCell];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return MAX(1, daySectionNodes.count);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (daySectionNodes.count > 1)
    {
        TreeNode *node = [daySectionNodes objectAtIndex:section];
        if ([node.data isKindOfClass:[DateGroupingNodeData class]])
        {
            DateGroupingNodeData *data = node.data;
            
            NSDateFormatter *sectionDateFormatter = [NSDateFormatter new];
            sectionDateFormatter.dateFormat = @"MMMM dd";
            
            return [monthDayDateFormatter stringFromDate:data.groupingTimestamp];
        }
    }
    
    return [super tableView:tableView titleForHeaderInSection:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (daySectionNodes.count > 0)
    {
        TreeNode *node = [daySectionNodes objectAtIndex:section];
        if (node.numSubtreeLeaves > 0)
        {
            return node.numSubtreeLeaves;
        }
    }

    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (leafNodes.count == 0)
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
        static NSString *CellIdentifier = @"timeCell";
        
        UINib *audioTableCellLoader = [UINib nibWithNibName:@"AudioTableCell" bundle:nil];
        // In tableView:cellForRowAtIndexPath:
        AudioTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[audioTableCellLoader instantiateWithOwner:self options:nil] objectAtIndex:0];
        }
        cell.delegate = self;
        
        DateGroupingNodeData *nodeData = nil;
        
        TreeNode *dayNode = [daySectionNodes objectAtIndex:indexPath.section];
        TreeNode *leafNode = [dayNode childAtIndex:indexPath.row];

        int leafIndex = [leafNodes indexOfObject:leafNode];
        
        nodeData = (DateGroupingNodeData *)leafNode.data;
        
        if (nodeData != nil && nodeData.capturedContext != nil)
        {
            CapturedContext *capturedContext = nodeData.capturedContext;
            
            [cell setCapturedContext:capturedContext rowIndex:leafIndex totalRowCount:rootNode.numSubtreeLeaves];
        }
        
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!leafNodes.count == 0)
    {
        [self performSegueWithIdentifier:@"showCapturedContextDetailScrollViewSegue" sender:self];
    }
}

#pragma mark - AvAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    // TODO: check if what stopped was memo or ambient
    if ([player.url.path isEqualToString:currentlyPlayingCell.capturedContext.memoFilePath] &&
        currentlyPlayingCell.capturedContext.ambientAudioFileExists)
    {
        // Finished playing memo, so start playing ambient audio, if it exists
        NSError *error = nil;
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:currentlyPlayingCell.capturedContext.ambientAudioFilePath] error:&error];
        audioPlayer.delegate = self;
        
        if (error)
        {
            NSLog(@"ERROR: AudioPreviewViewController: Could not start playing audio file at %@: %@", audioPlayer.url.path, error.localizedDescription);
            audioPlayer = nil;
            [self signalAudioFinishedPlayingToCurrentlyPlayingCell];
        }
        else
        {
            // FIX: play some kind of sound to demarcate the two sounds?
            
            [audioPlayer play];
        }
    }
    else
    {
        audioPlayer = nil;
        [self signalAudioFinishedPlayingToCurrentlyPlayingCell];
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"ERROR: AudioPreviewViewController: Error playing audio at %@: %@", player.url.path, error.localizedDescription);
    audioPlayer = nil;
    [self signalAudioFinishedPlayingToCurrentlyPlayingCell];
}

#pragma mark - CapturedContextDetailScrollViewControllerDelegate

- (void)capturedContextDetailScrollViewController:(CapturedContextDetailScrollViewController *)sender focusedPageIndexChangedTo:(int)pageIndex
{
//    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:pageIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
}

@end
