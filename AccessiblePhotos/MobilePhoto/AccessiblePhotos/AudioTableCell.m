//
//  AudioTableCell.m
//  AccessiblePhotos
//
//  Created by Adams Dustin on 7/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AudioTableCell.h"
#import "CapturedContext.h"
#import <AVFoundation/AVFoundation.h>

@implementation AudioTableCell
{
    AVAudioPlayer *audioPlayer;
    AVAudioPlayer *audioPlayerForButton;
}
@synthesize delegate;
@synthesize capturedContext;
@synthesize image;
@synthesize timeLabel;


-(void)pressPlay
{
    //NSLog(@"Element in the table cell became focused");
    if (audioPlayerForButton != nil)
    {
        [audioPlayerForButton stop];
        audioPlayerForButton = nil;
    }
    
    // Below, we get the url of the audio file we'll be playing
    NSError *error;
    audioPlayerForButton = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:capturedContext.audioFilePath] error:&error];
    
    if (error)
    {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    else
    {
        [audioPlayerForButton play];
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)accessibilityElementDidBecomeFocused
{
    NSLog(@"Element in the table cell became focused");
    [self audioTableCellAccessibilityElementDidBecomeFocused:capturedContext];
}

- (void)accessibilityElementDidLoseFocus
{
    NSLog(@"Element in the table cell became focused");
    [self audioTableCellAccessibilityElementDidLoseFocus:capturedContext];
}

- (void)audioTableCellAccessibilityElementDidBecomeFocused:(CapturedContext *)sender
{
    //NSLog(@"Element in the table cell became focused");
    if (audioPlayer != nil)
    {
        [audioPlayer stop];
        audioPlayer = nil;
    }
    
    // Below, we get the url of the audio file we'll be playing
    NSError *error;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:capturedContext.audioFilePath] error:&error];
    
    if (error)
    {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    else
    {
        [audioPlayer play];
    }
}

- (void)audioTableCellAccessibilityElementDidLoseFocus:(CapturedContext *)sender
{
    //NSLog(@"Element in the table cell became focused");
    if (audioPlayer != nil)
    {
        [audioPlayer stop];
        audioPlayer = nil;
    }
}

@end
