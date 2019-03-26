//
//  ScrollViewController.m
//  NewAppPrototype
//
//  Created by Adams Dustin on 12/07/04.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ScrollViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import "CapturedContext.h"
#import "CapturedContextManager.h"

@interface ScrollViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@end

@implementation ScrollViewController
{
    AVAudioPlayer *audioPlayer;
    int currentPage;
}

@synthesize scrollView;

#pragma mark - UIViewController overrides

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    int numCapturedContexts = [CapturedContextManager sharedManager].capturedContexts.count;
    
    if (numCapturedContexts > 0)
    {
        CGRect pageFrame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        
        // Expand the scroll view to be wide enough to hold all the pages.
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * numCapturedContexts, self.scrollView.frame.size.height);
        
        CGRect dateLabelFrame = CGRectMake(0, 0, pageFrame.size.width, 30);
        CGRect timeLabelFrame = CGRectMake(0, 30, pageFrame.size.width, 30);
        CGRect imageViewFrame = CGRectMake(0, 0, pageFrame.size.width, pageFrame.size.height);
        
        // For each of the captured contexts
        for (CapturedContext *capturedContext in [CapturedContextManager sharedManager].capturedContexts)
        {
            UIView *pageView = [[UIView alloc] initWithFrame:pageFrame];
            UILabel *dateLabel = [[UILabel alloc] initWithFrame:dateLabelFrame];
            UILabel *timeLabel = [[UILabel alloc] initWithFrame:timeLabelFrame];
            
            dateLabel.text = [NSString stringWithFormat:@"Date: %@", [NSDateFormatter localizedStringFromDate:capturedContext.timestamp dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterNoStyle]];
            dateLabel.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6];
            timeLabel.text = [NSString stringWithFormat:@"Time: %@", [NSDateFormatter localizedStringFromDate:capturedContext.timestamp dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterFullStyle]];
            timeLabel.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
            imageView.image = capturedContext.uiImage;
            
            [pageView addSubview:imageView];
            [pageView addSubview:dateLabel];
            [pageView addSubview:timeLabel];
            [self.scrollView addSubview:pageView];
            
            // Shift all the page frame over by a page
            pageFrame = CGRectOffset(pageFrame, pageFrame.size.width, 0);
        }
        
        currentPage = 0;
    }
    else
    {
        UILabel *label = [[UILabel alloc] initWithFrame:self.scrollView.frame];
        label.text = @"Photo album empty";
        label.textAlignment = UITextAlignmentCenter;
        [self.scrollView addSubview:label];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self handlePageChanged];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (audioPlayer != nil)
    {
        [audioPlayer stop];
        audioPlayer = nil;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // Calculate the updated page number.
    int newPage = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
    
    if(newPage != currentPage)
    {
        currentPage = newPage;
        [self handlePageChanged];
    }
}

#pragma mark - Private class methods

- (void)handlePageChanged
{
    // Get the CapturedContext corresponding to the current page.
    CapturedContext *capturedContext = [[CapturedContextManager sharedManager].capturedContexts objectAtIndex:currentPage];
    
    // Just to be nice, if there was a previous instance of audio player already playing,
    // stop it first.
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

@end
