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
#import "UserManager.h"
#import "WebRequestManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "FileUtils.h"
#import "Settings.h"

@interface ButtonBasedContextCaptureViewController () <AVAudioRecorderDelegate>

@property (nonatomic, weak) IBOutlet UIView *backgroundGestureView;
@property (nonatomic, weak) IBOutlet UIButton *quickCaptureButton;
@property (nonatomic, weak) IBOutlet UIButton *captureAndSendButton;
@property (nonatomic, weak) IBOutlet UIButton *doneButton;
@property (nonatomic, weak) IBOutlet UIButton *playbackVideoButton;

@property (nonatomic, weak) IBOutlet UIButton *switchCameraButton;
@property (nonatomic, weak) IBOutlet UIButton *startStopVideoRecordingButton;

- (IBAction)quickCaptureButtonTapped:(id)sender;
- (IBAction)captureButtonTapped:(id)sender;
- (IBAction)goToAlbumButtonTapped:(id)sender;
- (IBAction)switchCameraButtonTapped:(id)sender;

- (IBAction)startStopVideoButtonTapped:(id)sender;
- (IBAction)playVideo:(id)sender;

@end

@implementation ButtonBasedContextCaptureViewController
{
    BOOL isRecordingVideo;

    id moviePlayerPlaybackDidFinishObserver;
    
    BOOL buttonsHidden;
}

@synthesize backgroundGestureView;
@synthesize quickCaptureButton;
@synthesize captureAndSendButton;
@synthesize doneButton;
@synthesize playbackVideoButton;
@synthesize switchCameraButton;
@synthesize startStopVideoRecordingButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    [self.backgroundGestureView addGestureRecognizer:tapRecognizer];
    
    if ([Settings sharedInstance].interfaceType == kInterfaceTypeStandard)
    {
        self.startStopVideoRecordingButton.hidden = YES;
        self.playbackVideoButton.hidden = YES;
    }
}

#pragma mark - IBAction methods

- (IBAction)quickCaptureButtonTapped:(id)sender
{
//    [super captureCameraFrameAndStopCameraFrameCapture:YES stopAudioCapture:YES];
//    [super justSaveCapturedContextToAlbum];
    [super saveCapturedContextAndResumeCaptureWithCompletion:nil];
}

- (IBAction)captureButtonTapped:(id)sender
{
//    [super captureCameraFrameAndStopCameraFrameCapture:YES stopAudioCapture:YES];
//    [super promptWhatToDoWithCapturedContext];
    [super saveCapturedContextAndPromptWhatToDo];
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

- (void)startStopVideoButtonTapped:(id)sender
{
    isRecordingVideo = !isRecordingVideo;
    
    if (isRecordingVideo)
    {
        [self.startStopVideoRecordingButton setTitle:@"Stop recording" forState:UIControlStateNormal];
        NSString *movieFilepath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"test.mp4"];
        [super.contextCaptureHelper.cameraFrameCaptureHelper startRecordingVideoToFile:movieFilepath];
    }
    else
    {
        [self.startStopVideoRecordingButton setTitle:@"Record video" forState:UIControlStateNormal];
        [super.contextCaptureHelper.cameraFrameCaptureHelper stopRecordingVideo];
    }
}

- (void)playVideo:(id)sender
{
    [super.contextCaptureHelper stopPhodioCaptureWithCompletion:^(ContextCaptureHelper *sender, BOOL success) {
        // TODO: discard phodio?
        
        NSString *movieFilepath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"test.mp4"];
        NSURL *videoURL=[[NSURL alloc] initFileURLWithPath:movieFilepath];
        
        MPMoviePlayerViewController *moviePlayerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
        
        moviePlayerPlaybackDidFinishObserver = [[NSNotificationCenter defaultCenter] addObserverForName:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayerViewController queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note)
                                                {
                                                    NSLog(@"Finished playing movie");
                                                    [[NSNotificationCenter defaultCenter] removeObserver:moviePlayerPlaybackDidFinishObserver];;
                                                    moviePlayerPlaybackDidFinishObserver = nil;
                                                    
                                                    [self dismissModalViewControllerAnimated:YES];
                                                    
//                                                    [super startAmbientAudioCapture];
//                                                    [super startCameraFrameCapture];
                                                    [super.contextCaptureHelper startPhodioCapture];
                                                }];
        
        [self presentMoviePlayerViewControllerAnimated:moviePlayerViewController];
        
        NSLog(@"Started playing movie");
    }];
//    [super stopAudioCaptureAndKeepAudioFile:NO];
//    [super stopCameraFrameCapture];
    
//    NSString *movieFilepath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"test.mp4"];
//    NSURL *videoURL=[[NSURL alloc] initFileURLWithPath:movieFilepath];
//    
//    MPMoviePlayerViewController *moviePlayerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
//    
//    moviePlayerPlaybackDidFinishObserver = [[NSNotificationCenter defaultCenter] addObserverForName:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayerViewController queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note)
//    {
//        NSLog(@"Finished playing movie");
//        [[NSNotificationCenter defaultCenter] removeObserver:moviePlayerPlaybackDidFinishObserver];;
//        moviePlayerPlaybackDidFinishObserver = nil;
//
//        [self dismissModalViewControllerAnimated:YES];
//
//        [super startAmbientAudioCapture];
//        [super startCameraFrameCapture];
//    }];
//
//    [self presentMoviePlayerViewControllerAnimated:moviePlayerViewController];
//    
//    NSLog(@"Started playing movie");
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer
{
    [UIView animateWithDuration:0.25 animations:^{
        if (buttonsHidden == YES)
        {
            buttonsHidden = NO;
            self.quickCaptureButton.alpha = 0.6;
            self.captureAndSendButton.alpha = 0.6;
            self.doneButton.alpha = 0.6;
            self.playbackVideoButton.alpha = 0.6;
            self.switchCameraButton.alpha = 0.6;
            self.startStopVideoRecordingButton.alpha = 0.6;
        }
        else
        {
            buttonsHidden = YES;
            self.quickCaptureButton.alpha = 0.0;
            self.captureAndSendButton.alpha = 0.0;
            self.doneButton.alpha = 0.0;
            self.playbackVideoButton.alpha = 0.0;
            self.switchCameraButton.alpha = 0.0;
            self.startStopVideoRecordingButton.alpha = 0.0;
        }
    }];
}

@end
