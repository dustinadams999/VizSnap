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

@interface ButtonBasedContextCaptureViewController () <UIActionSheetDelegate, AVAudioRecorderDelegate>

@property (nonatomic, weak) IBOutlet UIButton *switchCameraButton;
@property (nonatomic, weak) IBOutlet UIButton *startStopVideoRecordingButton;

- (IBAction)quickCaptureButtonTapped:(id)sender;
- (IBAction)captureButtonTapped:(id)sender;
- (IBAction)goToAlbumButtonTapped:(id)sender;
- (IBAction)switchCameraButtonTapped:(id)sender;

- (IBAction)startStopVideoButtonTapped:(id)sender;

- (IBAction)playVideo:(id)sender;
- (IBAction)viewPhoto:(id)sender;

@end

@implementation ButtonBasedContextCaptureViewController
{
    BOOL isRecordingVideo;

    id moviePlayerPlaybackDidFinishObserver;

    UIImageView *imageView;
}

@synthesize switchCameraButton;
@synthesize startStopVideoRecordingButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(200, 300, 100, 150)];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    [imageView addGestureRecognizer:tapRecognizer];
    imageView.hidden = YES;

    [self.view addSubview:imageView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self startAudioCapture];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
        
    [self stopAudioCapture];
}

#pragma mark - IBAction methods

- (IBAction)quickCaptureButtonTapped:(id)sender
{
    [super captureCameraFrameAndStopCameraFrameCapture:YES stopAudioCapture:YES];
    [super justSaveCapturedContextToAlbum];
}

- (IBAction)captureButtonTapped:(id)sender
{
    [super captureCameraFrameAndStopCameraFrameCapture:YES stopAudioCapture:YES];

    [self promptWhatToDoWithCapturedContext];
}

- (IBAction)goToAlbumButtonTapped:(id)sender
{
    [self exitCapture];
}

- (void)switchCameraButtonTapped:(id)sender
{
    [super.cameraFrameCaptureHelper switchCameras];
    
    NSString *buttonLabel = [super.cameraFrameCaptureHelper isUsingFrontCamera] ? @"Switch to back camera" : @"Switch to front camera";
    self.switchCameraButton.accessibilityLabel = buttonLabel;
}

- (void)startStopVideoButtonTapped:(id)sender
{
    isRecordingVideo = !isRecordingVideo;
    
    if (isRecordingVideo)
    {
        [self.startStopVideoRecordingButton setTitle:@"Stop recording video" forState:UIControlStateNormal];
        NSString *movieFilepath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"test.mp4"];
        [super.cameraFrameCaptureHelper startRecordingVideoToFile:movieFilepath];
    }
    else
    {
        [self.startStopVideoRecordingButton setTitle:@"Start recording video" forState:UIControlStateNormal];
        [super.cameraFrameCaptureHelper stopRecordingVideo];
    }
}

- (void)playVideo:(id)sender
{
    [super stopAudioCapture];
    [super stopCameraFrameCapture];
    
    NSString *movieFilepath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"test.mp4"];
    NSURL *videoURL=[[NSURL alloc] initFileURLWithPath:movieFilepath];
    
    MPMoviePlayerViewController *moviePlayerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
    
    moviePlayerPlaybackDidFinishObserver = [[NSNotificationCenter defaultCenter] addObserverForName:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayerViewController queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note)
    {
        NSLog(@"Finished playing movie");
        [[NSNotificationCenter defaultCenter] removeObserver:moviePlayerPlaybackDidFinishObserver];;
        moviePlayerPlaybackDidFinishObserver = nil;

        [self dismissModalViewControllerAnimated:YES];

        [super startAudioCapture];
        [super startCameraFrameCapture];
    }];

    [self presentMoviePlayerViewControllerAnimated:moviePlayerViewController];
    
    NSLog(@"Started playing movie");
}

- (void)viewPhoto:(id)sender
{
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"test.jpg"]];
    
    imageView.image = image;
    imageView.hidden = NO;
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"Closing image view");
    imageView.image = nil;
    imageView.hidden = YES;
    [self.view setNeedsDisplay];
}
   
#pragma mark - Private instance methods

- (void)promptWhatToDoWithCapturedContext
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Pick an action"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:@"Discard"
                                              otherButtonTitles:@"Save", @"Add memo", nil];
    
//    if ([UserManager sharedManager].currentUser != nil &&
//        [UserManager sharedManager].currentUser.supporterGroups.count > 0)
//    {
//        for (NSString *group in [UserManager sharedManager].currentUser.supporterGroups)
//        {
//            [sheet addButtonWithTitle:[NSString stringWithFormat:@"Send to %@", group]];
//        }
//    }
    
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex)
    {
        // Discard
        [super discardCapturedContext];
    }
    else if (buttonIndex == actionSheet.firstOtherButtonIndex)
    {
        // Save
        [super justSaveCapturedContextToAlbum];
        
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Saved");
    }
    else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1)
    {
        // Add memo
        
        // TODO
    }
//    else
//    {
//        // One of the groups chosen
//        int groupIndex = buttonIndex - (actionSheet.firstOtherButtonIndex + 2);
//        [super saveCapturedContextAndSendToGroup:[[UserManager sharedManager].currentUser.supporterGroups objectAtIndex:groupIndex]];
//    }
}

@end
