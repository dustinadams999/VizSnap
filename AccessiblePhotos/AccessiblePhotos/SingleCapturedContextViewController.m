//
//  SingleCapturedContextViewController.m
//  AccessiblePhotos
//
//  Created by Adams Dustin on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SingleCapturedContextViewController.h"
#import "CapturedContextManager.h"
#import "CapturedContext.h"
#import "AudioTableViewController.h"
#import "ByDateTableViewController.h"
#import <AVFoundation/AVFoundation.h>


@interface SingleCapturedContextViewController ()

@end

@implementation SingleCapturedContextViewController
{
    AVAudioPlayer *audioPlayer;
}

@synthesize capturedContext;
@synthesize timeLabel;
@synthesize dateLabel;
@synthesize locationLabel;
@synthesize imageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    dateLabel.text = [NSString stringWithFormat:@"Date: %@", [NSDateFormatter localizedStringFromDate:capturedContext.timestamp dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterNoStyle]];
    dateLabel.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6];
    timeLabel.text = [NSString stringWithFormat:@"Time: %@", [NSDateFormatter localizedStringFromDate:capturedContext.timestamp dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterFullStyle]];
    timeLabel.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6];
    if (capturedContext.placemark != nil)
    {
        locationLabel.text = [NSString stringWithFormat:@"Location: %@, %@, %@", capturedContext.placemark.country, capturedContext.placemark.administrativeArea, capturedContext.placemark.subLocality];
    }
    else
    {
        locationLabel.text = @"Location: (not available)";
    }
    locationLabel.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6];
    imageView.image = capturedContext.uiImage;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [audioPlayer stop];
}

//delete the current captured context
- (IBAction)deleteCurrentCapturedContext:(id)sender
{
    [audioPlayer stop];

    CapturedContext *currentCapturedContext = capturedContext;
    NSString *timestampString = [NSDateFormatter localizedStringFromDate:currentCapturedContext.timestamp dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterLongStyle];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete current photo?"
                                                    message:[NSString stringWithFormat:@"Are you sure you want to delete the currently selected photo taken at %@?", timestampString]
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Delete", nil];
    [alert show];
}

- (IBAction)playAudio
{
    if (audioPlayer != nil)
    {
        [audioPlayer stop];
        audioPlayer = nil;
    }
    
    // Below, we get the url of the audio file we'll be playing
    NSError *error = nil;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:capturedContext.ambientAudioFilePath] error:&error];
    
    if (error)
    {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    else
    {
        [audioPlayer play];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        CapturedContext *currentCapturedContext = capturedContext;
        
        [[CapturedContextManager sharedManager] permanentlyDeleteCapturedContext:currentCapturedContext];
        
        NSLog(@"Deleted photo.");
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Deleted photo.");
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
