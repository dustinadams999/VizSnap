//
//  ButtonBasedContextCaptureViewController.m
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/07/24.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "ButtonBasedContextCaptureViewController.h"
#import "ContextCaptureViewController_Protected.h"
#import "ContextCaptureViewController.h"
#import "CapturedContextManager.h"
//#import "UserManager.h"
//#import "WebRequestManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "FileUtils.h"
#import "Settings.h"

@interface ButtonBasedContextCaptureViewController () <AVAudioRecorderDelegate>

@property (nonatomic, weak) IBOutlet UIView *backgroundGestureView;
@property (nonatomic, weak) IBOutlet UIButton *quickCaptureButton;
@property (nonatomic, weak) IBOutlet UIButton *doneButton;
@property (nonatomic, weak) IBOutlet UIButton *playbackVideoButton;

@property (nonatomic, weak) IBOutlet UIButton *switchCameraButton;

- (IBAction)quickCaptureButtonTapped:(id)sender;
- (IBAction)goToAlbumButtonTapped:(id)sender;
- (IBAction)switchCameraButtonTapped:(id)sender;


@end

@implementation ButtonBasedContextCaptureViewController
{
    BOOL isRecordingVideo;

    id moviePlayerPlaybackDidFinishObserver;
    
    BOOL buttonsHidden;
    UILabel *recordingAudioLabel;
    bool recordingLabelIsShowing;
}

@synthesize backgroundGestureView;
@synthesize quickCaptureButton;
@synthesize doneButton;
@synthesize playbackVideoButton;
@synthesize switchCameraButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    [self.backgroundGestureView addGestureRecognizer:tapRecognizer];
    
    if ([Settings sharedInstance].interfaceType == kInterfaceTypeStandard)
    {
        self.playbackVideoButton.hidden = YES;
    }
    
    //add the Recording Audio label
    recordingAudioLabel = [UILabel new];
    [recordingAudioLabel setText:@"Recording Audio"];
    [recordingAudioLabel setTextColor:[UIColor redColor]];
    [recordingAudioLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [recordingAudioLabel setFrame:CGRectMake(173, self.view.frame.size.height - 100, 140, 21)];
    [self.view addSubview:recordingAudioLabel];
    [recordingAudioLabel setHidden:false];
    
    //change the buttons to have a background of white
    [quickCaptureButton setBackgroundColor:[UIColor whiteColor]];
    [switchCameraButton setBackgroundColor:[UIColor whiteColor]];
    [doneButton setBackgroundColor:[UIColor whiteColor]];
    
    recordingLabelIsShowing = true;
    
    [NSTimer scheduledTimerWithTimeInterval:.5
                                     target:self
                                   selector:@selector(changeLabel)
                                   userInfo:nil
                                    repeats:YES];
}

-(void)changeLabel
{
    if (recordingLabelIsShowing)
    {
        [recordingAudioLabel setHidden:true];
        recordingLabelIsShowing = false;
    }
    else
    {
        [recordingAudioLabel setHidden:false];
        recordingLabelIsShowing = true;
    }
}

#pragma mark - IBAction methods

- (IBAction)quickCaptureButtonTapped:(id)sender
{
//    [super captureCameraFrameAndStopCameraFrameCapture:YES stopAudioCapture:YES];
//    [super justSaveCapturedContextToAlbum];
    [super saveCapturedContextAndResumeCaptureWithCompletion:nil];
}

- (IBAction)goToAlbumButtonTapped:(id)sender
{
    [self exitCapture];
}

- (void)switchCameraButtonTapped:(id)sender
{
    [super.contextCaptureHelper.cameraFrameCaptureHelper switchCameras];
    
    NSString *buttonLabel = [super.contextCaptureHelper.cameraFrameCaptureHelper isUsingFrontCamera] ? @"Switch to back camera" : @"Switch to front camera";
    self.switchCameraButton.accessibilityLabel = buttonLabel;
}


- (void)handleTap:(UITapGestureRecognizer *)recognizer
{
    [UIView animateWithDuration:0.25 animations:^{
        if (buttonsHidden == YES)
        {
            buttonsHidden = NO;
            self.quickCaptureButton.alpha = 0.6;
            self.doneButton.alpha = 0.6;
            self.playbackVideoButton.alpha = 0.6;
            self.switchCameraButton.alpha = 0.6;
        }
        else
        {
            buttonsHidden = YES;
            self.quickCaptureButton.alpha = 0.0;
            self.doneButton.alpha = 0.0;
            self.playbackVideoButton.alpha = 0.0;
            self.switchCameraButton.alpha = 0.0;
        }
    }];
}

@end
