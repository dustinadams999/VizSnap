//
//  DateScrollViewController.m
//  NewAppPrototype
//
//  Created by Adams Dustin on 12/07/12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CapturedContextScrollViewController.h"
#import "CapturedContext.h"
#import "CapturedContextManager.h"
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>

@interface CapturedContextScrollViewController () <UIScrollViewDelegate>

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

- (IBAction)deleteCurrentCapturedContext:(id)sender;

@end

@implementation CapturedContextScrollViewController
{
    NSArray *capturedContexts;
    AVAudioPlayer *audioPlayer;
    AVAudioPlayer *memoPlayer;
    int currentPage;
    UITapGestureRecognizer *oneFingerDoubleTapRecognizer, *oneFingerSingleTapRecognizer;
}

@synthesize mainTitle;
@synthesize scrollView = _scrollView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mainTitle = @"All";

    capturedContexts = [self updateCapturedContextList];
    
    oneFingerDoubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    oneFingerDoubleTapRecognizer.numberOfTouchesRequired = 1;
    oneFingerDoubleTapRecognizer.numberOfTapsRequired = 2;
    [self.scrollView addGestureRecognizer:oneFingerDoubleTapRecognizer];
    oneFingerDoubleTapRecognizer.delegate = self;
    
    oneFingerSingleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    oneFingerSingleTapRecognizer.numberOfTouchesRequired = 1;
    oneFingerSingleTapRecognizer.numberOfTapsRequired = 1;
    [oneFingerSingleTapRecognizer requireGestureRecognizerToFail:oneFingerDoubleTapRecognizer];
    [self.scrollView addGestureRecognizer:oneFingerSingleTapRecognizer];
    oneFingerSingleTapRecognizer.delegate = self;

//        currentPage = 0;
    // Uncomment below to start with the most recent photo in view
    currentPage = capturedContexts.count - 1;
}

- (void)handleTapGesture:(UIGestureRecognizer *)gestureRecognizer
{
    /*UITapGestureRecognizer *tapGestureRecognizer = (UITapGestureRecognizer *)gestureRecognizer;
    int numTouches = tapGestureRecognizer.numberOfTouchesRequired;
    int numTaps = tapGestureRecognizer.numberOfTapsRequired;
    
    if ([self.delegate respondsToSelector:@selector(captureGestureHandler:recognizedTapGestureWithNumTaps:withNumTouches:)])
    {
        [self.delegate captureGestureHandler:self recognizedTapGestureWithNumTaps:numTaps withNumTouches:numTouches];
    }*/
    //capturedContexts = [self updateCapturedContextList];
    if (capturedContexts.count > 0)
    {
        //self.title = [NSString stringWithFormat:@"%@ (%d/%d)", self.mainTitle, (currentPage + 1), capturedContexts.count];
        
        // Get the CapturedContext corresponding to the current page.
        CapturedContext *capturedContext = [capturedContexts objectAtIndex:currentPage];
        
        // Just to be nice, if there was a previous instance of audio player already playing,
        // stop it first.
        if (memoPlayer != nil)
        {
            [memoPlayer stop];
            memoPlayer = nil;
        }
        
        //First, make sure the capturedContext actually has a voice memo
        if (capturedContext.hasMemo)
        {
        
            // Below, we get the url of the audio file we'll be playing
            NSError *error;
            memoPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:capturedContext.memoFilePath] error:&error];
        
            if (error)
            {
                NSLog(@"Error: %@", [error localizedDescription]);
            }
            else
            {
                [memoPlayer play];
            }
        }
    }
    else
    {
        //self.title = self.mainTitle;
    }

}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	// Do any additional setup after loading the view.

    [self relayoutPhotos];
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
    if (memoPlayer != nil)
    {
        [memoPlayer stop];
        memoPlayer = nil;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)deleteCurrentCapturedContext:(id)sender
{
    CapturedContext *currentCapturedContext = [capturedContexts objectAtIndex:currentPage];
    NSString *timestampString = [NSDateFormatter localizedStringFromDate:currentCapturedContext.timestamp dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterLongStyle];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete current photo?"
                                                    message:[NSString stringWithFormat:@"Are you sure you want to delete the currently selected photo taken at %@?", timestampString]
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Delete", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        CapturedContext *currentCapturedContext = [capturedContexts objectAtIndex:currentPage];

        NSError *error;

        if ([[NSFileManager defaultManager] fileExistsAtPath:currentCapturedContext.photoFilePath])
        {
            if ([[NSFileManager defaultManager] removeItemAtPath:currentCapturedContext.photoFilePath error:&error] == NO)
            {
                NSLog(@"Error removing photo at %@, error: %@", currentCapturedContext.photoFilePath, [error localizedDescription]);
            }
        }
        if ([[NSFileManager defaultManager] fileExistsAtPath:currentCapturedContext.audioFilePath])
        {
            if ([[NSFileManager defaultManager] removeItemAtPath:currentCapturedContext.audioFilePath error:&error] == NO)
            {
                NSLog(@"Error removing audio at %@, error: %@", currentCapturedContext.audioFilePath, [error localizedDescription]);
            }
        }
        
        NSLog(@"Deleted photos.");
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Deleted photo.");
        
        [[CapturedContextManager sharedManager].capturedContexts removeObject:currentCapturedContext];
        [[CapturedContextManager sharedManager] saveCapturedContextList];

        capturedContexts = [self updateCapturedContextList];

        if (currentPage >= capturedContexts.count) 
        {
            currentPage = capturedContexts.count - 1;
        }
        
        [self relayoutPhotos];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // TODO: optimize loading of images by only loading in images when the page is about to become visible.

    //int newVisibleFirstPage = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
}

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

- (NSArray *)updateCapturedContextList
{
    // Overridden by subclass
    return [NSArray arrayWithArray:[CapturedContextManager sharedManager].capturedContexts];
}

- (void)clearScrollView
{
    NSArray *subviews = [NSArray arrayWithArray:self.scrollView.subviews];
    for (UIView *subview in subviews)
    {
        [subview removeFromSuperview];
    }
}

- (void)relayoutPhotos
{
    // First clear out the scroll view.
    [self clearScrollView];
    
    int numCapturedContexts = capturedContexts.count;
    
    if (numCapturedContexts > 0)
    {
        CGRect pageFrame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        
        // Expand the scroll view to be wide enough to hold all the pages.
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * numCapturedContexts, self.scrollView.frame.size.height);
        
        
        CGRect dateLabelFrame = CGRectMake(0, 0, pageFrame.size.width, 30);
        CGRect timeLabelFrame = CGRectMake(0, 30, pageFrame.size.width, 30);
        CGRect locationLabelFrame = CGRectMake(0, 60, pageFrame.size.width, 30);
        CGRect imageViewFrame = CGRectMake(0, 0, pageFrame.size.width, pageFrame.size.height);
        
        // For each of the captured contexts
        for (CapturedContext *capturedContext in capturedContexts)
        {
            UIView *pageView = [[UIView alloc] initWithFrame:pageFrame];
            UILabel *dateLabel = [[UILabel alloc] initWithFrame:dateLabelFrame];
            UILabel *timeLabel = [[UILabel alloc] initWithFrame:timeLabelFrame];
            UILabel *locationLabel = [[UILabel alloc] initWithFrame:locationLabelFrame];
            
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
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
            imageView.image = capturedContext.uiImage;
            
            [pageView addSubview:imageView];
            [pageView addSubview:dateLabel];
            [pageView addSubview:timeLabel];
            [pageView addSubview:locationLabel];
            [self.scrollView addSubview:pageView];
            
            // Shift the page frame over by a page
            pageFrame = CGRectOffset(pageFrame, pageFrame.size.width, 0);
        }
        
        self.scrollView.contentOffset = CGPointMake(currentPage * pageFrame.size.width, 0);
    }
    else
    {
        UILabel *label = [[UILabel alloc] initWithFrame:self.scrollView.frame];
        label.text = @"Photo album empty";
        label.textAlignment = UITextAlignmentCenter;
        [self.scrollView addSubview:label];
    }
}

- (void)handlePageChanged
{
    if (capturedContexts.count > 0)
    {
        //self.title = [NSString stringWithFormat:@"%@ (%d/%d)", self.mainTitle, (currentPage + 1), capturedContexts.count];
        
        // Get the CapturedContext corresponding to the current page.
        CapturedContext *capturedContext = [capturedContexts objectAtIndex:currentPage];
        
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
    else
    {
        //self.title = self.mainTitle;
    }
}

@end
