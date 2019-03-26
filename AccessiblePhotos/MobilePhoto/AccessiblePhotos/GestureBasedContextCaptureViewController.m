//
//  GestureBasedContextCaptureViewController.m
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/07/24.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "GestureBasedContextCaptureViewController.h"
#import "AccessibleGestureView.h"
#import "CaptureGestureHandler.h"
#import "ContextCaptureViewController_Protected.h"
#import "UserManager.h"

@interface GestureBasedContextCaptureViewController () <AccessibleGestureViewDelegate,  CaptureGestureHandlerDelegate, UIActionSheetDelegate>

@end

@implementation GestureBasedContextCaptureViewController
{
    UILabel *instructionLabel;
    AccessibleGestureView *accessibleGestureView;
    CaptureGestureHandler *captureGestureHandler;
}

@synthesize delegate;

- (void)dealloc
{
    NSLog(@"ImageCaptureViewController: dealloc called");
}

- (void)viewDidLoad
{
    NSLog(@"ImageCaptureViewController: viewDidLoad called");
    
    [super viewDidLoad];
    
    self.title = @"Camera view";
    
    
    //////////////////////////////////////////////
    // Set up the AccessibleGestureView to be able to process
    // various gestures performed over the camera view.
    accessibleGestureView = [[AccessibleGestureView alloc] initWithFrame:self.view.bounds];
    accessibleGestureView.delegate = self;
    accessibleGestureView.accessibilityLabel = @"Camera view";
    accessibleGestureView.accessibilityHint = @"First tap once to activate the camera, then tap again to capture a photo.";
    [self.view addSubview:accessibleGestureView];
    
    
    //////////////////////////////////////////////
    // Set up the gesture handler for processing gestures performed
    // on the accessibleGestureView.
    captureGestureHandler = [CaptureGestureHandler new];
    captureGestureHandler.delegate = self;
    captureGestureHandler.accessibleGestureView = accessibleGestureView;
    
    
    //////////////////////////////////////////////
    // Set up the instruction label to be overlayed over the
    // camera view for sighted users.
    instructionLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
    instructionLabel.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6];
    instructionLabel.isAccessibilityElement = NO;
    instructionLabel.numberOfLines = 8;
    instructionLabel.text = @"Single-tap (1-finger): capture photo\nSingle-tap (2-finger): toggle help\nSwipe left (1-finger): cancel\nSwipe down (1-finger): save to album\nSwipe up (1-finger): tag to send later\nSwipe right (1-finger): send to group";
    [self.view addSubview:instructionLabel];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"ImageCaptureViewController: viewDidAppear");
    
    [super viewDidAppear:animated];
    
    [super startAudioCapture];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"ImageCaptureViewController: viewDidDisappear");
    
    [super viewDidDisappear:animated];
    
    [super stopAudioCapture];
}

- (void)viewDidUnload
{
    NSLog(@"ImageCaptureViewController: viewDidUnload: self.view = %@", self.view);
    
    [super viewDidUnload];
    
    captureGestureHandler.accessibleGestureView = nil;
    captureGestureHandler.delegate = nil;
    captureGestureHandler = nil;
    
    accessibleGestureView.delegate = nil;
    accessibleGestureView = nil;
    instructionLabel = nil;
}

#pragma mark - Private instance methods

- (void)announceCurrentStatus
{
    if (super.capturedCameraFrame == nil)
    {
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Camera view is active and audio is recording. Tap once to capture a photo.");
    }
    else
    {
        // Camera frame has already been captured, so announce
        // instructions about the swipes that can be performed.
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"A photo has already been taken, and audio recording is continuing until you perform one of the following gestures. Swipe down to just save the photo to the album, swipe right to save the photo and select a group to send it to, swipe up to tag the photo for sending later, or swipe left to discard the photo and return to the camera mode.");
    }
}

#pragma mark - ContextCaptureViewController overrides

- (void)saveCapturedContextAndSendToGroup
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Select group to send to"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Just save to album", @"Tag to send later", nil];
    
    if ([UserManager sharedManager].currentUser != nil &&
        [UserManager sharedManager].currentUser.supporterGroups.count > 0)
    {
        for (NSString *group in [UserManager sharedManager].currentUser.supporterGroups)
        {
            [sheet addButtonWithTitle:[NSString stringWithFormat:@"Send to %@", group]];
        }
    }
    
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex)
    {
        // Cancel
        [super discardCapturedContext];
    }
    else if (buttonIndex == actionSheet.firstOtherButtonIndex)
    {
        // Just save to album
        [super justSaveCapturedContextToAlbum];
    }
    else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1)
    {
        // Tag to send later
        [super saveCapturedContextAndTagToBeSent];
    }
    else
    {
        // One of the groups chosen
        int groupIndex = buttonIndex - (actionSheet.firstOtherButtonIndex + 2);
        [super saveCapturedContextAndSendToGroup:[[UserManager sharedManager].currentUser.supporterGroups objectAtIndex:groupIndex]];
    }
}


#pragma mark - AccessibleGestureViewDelegate

- (void)accessibleGestureViewDidBecomeFocused:(AccessibleGestureView *)view
{
    accessibleGestureView.accessibilityLabel = @"Camera ready";
    accessibleGestureView.accessibilityHint = @"";
}

#pragma mark - CaptureGestureHandlerDelegate

- (void)captureGestureHandler:(CaptureGestureHandler *)sender recognizedLongPressGestureStartWithNumTaps:(int)numTaps withNumTouches:(int)numTouches
{
    //NSLog(@"Handler method called, numTaps: %d, numTouches: %d", numTaps, numTouches);
    //here, tell this handler to start recording the audio until the long press is released
    if (numTouches == 1 && numTaps == 0)
    {
        //here, call the captureVoiceMemo method
        //NSLog(@"Starting long press");
        //also, define what happens in the action sheet
        [super startVoiceMemoCapture];
    }
}

- (void)captureGestureHandler:(CaptureGestureHandler *)sender recognizedLongPressGestureEndWithNumTaps:(int)numTaps withNumTouches:(int)numTouches
{
    //NSLog(@"Handler method called, numTaps: %d, numTouches: %d", numTaps, numTouches);
    //here, tell this handler to start recording the audio until the long press is released
    if (numTouches == 1 && numTaps == 0)
    {
        //here, we need to stop the audio recording
        [super stopVoiceMemoCapture];
    }
}

- (void)captureGestureHandler:(CaptureGestureHandler *)sender recognizedTapGestureWithNumTaps:(int)numTaps withNumTouches:(int)numTouches
{
    if (numTouches == 1 && numTaps == 1)
    {
        // One-finger single tap
        if (super.capturedCameraFrame == nil)
        {
            // No camera frame has been captured yet, so interpret the tap
            // to mean capture the camera frame.
            [super captureCameraFrameAndStopCameraFrameCapture:YES stopAudioCapture:NO];
        }
        else
        {
            [self announceCurrentStatus];
        }
    }
    else if (numTouches == 1 && numTaps == 2)
    {
        // One-finger double-tap
        [self announceCurrentStatus];
    }
    else if (numTouches == 2 && numTaps == 1)
    {
        instructionLabel.hidden = !instructionLabel.isHidden;
    }
}

- (void)captureGestureHandler:(CaptureGestureHandler *)sender recognizedSwipeGestureWithSwipeDirection:(UISwipeGestureRecognizerDirection)direction withNumTouches:(int)numTouches
{
    if (numTouches == 1)
    {
        switch (direction) {
            case UISwipeGestureRecognizerDirectionLeft:
                if (super.capturedCameraFrame == nil)
                {
                    // No camera frame has been captured yet, so
                    // interpret the left swipe to mean cancel out of
                    // the camera view.
                    [super exitCapture];
                }
                else
                {
                    // Camera frame had been captured already, so
                    // interpret the left swipe to mean discard the
                    // captured camera frame.
                    [super discardCapturedContext];
                }
                
                break;
            case UISwipeGestureRecognizerDirectionDown:
                // Just save to album
                if (super.capturedCameraFrame == nil)
                {
                    // FIX: should we be snapping a photo for the user if
                    // a camera frame hasn't been captured yet?
                    [super captureCameraFrameAndStopCameraFrameCapture:YES stopAudioCapture:NO];
                }
                [self justSaveCapturedContextToAlbum];
                break;
            case UISwipeGestureRecognizerDirectionUp:
                // Tag for sending later
                if (super.capturedCameraFrame == nil)
                {
                    // FIX: should we be snapping a photo for the user if
                    // a camera frame hasn't been captured yet?
                    [super captureCameraFrameAndStopCameraFrameCapture:YES stopAudioCapture:NO];
                }
                [super saveCapturedContextAndTagToBeSent];
                break;
            case UISwipeGestureRecognizerDirectionRight:
                // Send to group
                if (super.capturedCameraFrame == nil)
                {
                    // FIX: should we be snapping a photo for the user if
                    // a camera frame hasn't been captured yet?
                    [super captureCameraFrameAndStopCameraFrameCapture:YES stopAudioCapture:NO];
                }
                [self saveCapturedContextAndSendToGroup];
                break;
                
            default:
                break;
        }
    }
}

@end
