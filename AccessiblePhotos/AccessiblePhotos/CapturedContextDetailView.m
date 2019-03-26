//
//  CapturedContextDetailView.m
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/08/09.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "CapturedContextDetailView.h"
#import <AVFoundation/AVFoundation.h>

@interface CapturedContextDetailView () <AVAudioPlayerDelegate>

@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (nonatomic, weak) IBOutlet UILabel *recordingDurationLabel;
@property (nonatomic, weak) IBOutlet UIButton *toggleAudioPlaybackButton;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *noPhotoLabel;

- (IBAction)toggleAudioPlaybackButtonTapped:(id)sender;

@end

@implementation CapturedContextDetailView
{
    AVAudioPlayer *audioPlayer;
    
    BOOL controlsHidden;
}

@synthesize capturedContext = _capturedContext;
@synthesize containerView;
@synthesize dateLabel;
@synthesize timeLabel;
@synthesize locationLabel;
@synthesize recordingDurationLabel;
@synthesize toggleAudioPlaybackButton;
@synthesize imageView;
@synthesize noPhotoLabel;
@synthesize delegate;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    singleTapRecognizer.numberOfTouchesRequired = 1;
    [self.imageView addGestureRecognizer:singleTapRecognizer];
//    self.imageView.accessibilityLabel = @" ";
    self.imageView.accessibilityLabel = @"";
    self.imageView.accessibilityHint = @"Information overlay is showing. Double tap to hide the overlay.";
    self.noPhotoLabel.hidden = YES;
}

#pragma mark - Property accessor methods

- (void)setCapturedContext:(CapturedContext *)capturedContext
{
    _capturedContext = capturedContext;

    if (self.capturedContext != nil)
    {
        self.imageView.image = self.capturedContext.uiImage;
        
        switch (self.imageView.image.imageOrientation) {
            case UIImageOrientationRight:
            case UIImageOrientationRightMirrored:
            case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored:
                self.imageView.accessibilityLabel = @"Vertical image.";
                break;
            case UIImageOrientationUp:
            case UIImageOrientationUpMirrored:
            case UIImageOrientationDown:
            case UIImageOrientationDownMirrored:
                self.imageView.accessibilityLabel = @"Horizontal image.";
                break;
        }
        
        self.noPhotoLabel.hidden = (self.capturedContext.uiImage != nil);
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.timeZone = self.capturedContext.timeZone;

        dateFormatter.dateStyle = NSDateFormatterFullStyle;
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
        self.dateLabel.text = [dateFormatter stringFromDate:capturedContext.timestamp];

        dateFormatter.dateStyle = NSDateFormatterNoStyle;
        dateFormatter.timeStyle = NSDateFormatterFullStyle;
        self.timeLabel.text = [dateFormatter stringFromDate:capturedContext.timestamp];
        
        if (capturedContext.placemark != nil)
        {
            self.locationLabel.text = [NSString stringWithFormat:@"Location: %@, %@, %@", capturedContext.placemark.country, capturedContext.placemark.administrativeArea, capturedContext.placemark.subLocality];
        }
        else
        {
            self.locationLabel.text = @"Unknown location";
        }
        
        if (capturedContext.ambientAudioFileExists)
        {
            self.recordingDurationLabel.text = [NSString stringWithFormat:@"Audio duration: %.1f sec", capturedContext.ambientAudioDuration];
            self.toggleAudioPlaybackButton.hidden = NO;
        }
        else
        {
            self.recordingDurationLabel.text = @"No audio recording";
            self.toggleAudioPlaybackButton.hidden = YES;
        }
    }
    else
    {
        self.noPhotoLabel.hidden = NO;
        self.imageView.image = nil;
        self.dateLabel.text = @"";
        self.locationLabel.text = @"";
    }
}

#pragma mark - Public instance methods

- (void)startPlayingAudio
{
    if (audioPlayer != nil && audioPlayer.isPlaying)
    {
        [self stopPlayingAudio];
    }
    
    // Below, we get the url of the audio file we'll be playing
    NSError *error;
    
    NSURL *audioFileURL = nil;
    if (self.capturedContext.memoAudioFileExists == YES)
    {
        audioFileURL = [NSURL fileURLWithPath:self.capturedContext.memoFilePath];
    }
    else if (self.capturedContext.ambientAudioFileExists == YES)
    {
        audioFileURL = [NSURL fileURLWithPath:self.capturedContext.ambientAudioFilePath];
    }
    
    if (audioFileURL != nil)
    {
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileURL error:&error];
        audioPlayer.delegate = self;
        
        if (error)
        {
            NSLog(@"ERROR: CapturedContextDetailView: unable to initialize audio player for %@: %@", audioFileURL.path, error.localizedDescription);
        }
        else
        {
            [audioPlayer play];
            [self handleAudioPlaybackStarted];
        }
    }
    else
    {
        NSLog(@"CapturedContextDetailView: NO memo or ambient audio file to play for captured context %@", self.capturedContext);
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"No memo or audio recording.");
    }
}

- (void)stopPlayingAudio
{
    if (audioPlayer != nil && audioPlayer.isPlaying)
    {
        [audioPlayer stop];
        audioPlayer = nil;
        
        [self handleAudioPlaybackStopped];
    }
}

- (void)hideInformationOverlay
{
    if (controlsHidden == NO)
    {
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Hiding Information overlay.");
        self.imageView.accessibilityHint = @"Information overlay is hidden. Double tap to show the overlay.";
        [UIView animateWithDuration:0.25 animations:^{
            self.containerView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.containerView.hidden = YES;
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
        }];
        
        controlsHidden = YES;
    }
}

- (void)showInformationOverlay
{
    if (controlsHidden == YES)
    {
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Showing information overlay.");
        self.imageView.accessibilityHint = @"Information overlay is showing. Double tap to hide the overlay.";
        [UIView animateWithDuration:0.25 animations:^{
            self.containerView.hidden = NO;
            self.containerView.alpha = 1.0;
        } completion:^(BOOL finished) {
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
        }];
        controlsHidden = NO;
    }
}

- (IBAction)emailPhoto:(id)sender
{
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"My Subject"];
    //NSData *data = [[NSData alloc] initWithContentsOfFile:@"0.jpg"];
    //UIImage *image = [UIImage imageNamed:@"0.jpg"];
    //NSData *data = UIImageJPEGRepresentation(image, .5);
    //[controller addAttachmentData:data mimeType:@"image/jpeg" fileName:@"0.jpg"];
    [controller setMessageBody:@"Hello there." isHTML:NO];
    
}

#pragma mark - IBAction methods

- (IBAction)toggleAudioPlaybackButtonTapped:(id)sender
{
    if (audioPlayer != nil && audioPlayer.isPlaying)
    {
        [self stopPlayingAudio];
    }
    else
    {
        [self startPlayingAudio];
    }
}

#pragma mark - Private instance methods



- (void)handleAudioPlaybackStarted
{
    [self.toggleAudioPlaybackButton setTitle:@"Stop" forState:UIControlStateNormal];
}

- (void)handleAudioPlaybackStopped
{
    [self.toggleAudioPlaybackButton setTitle:@"Play" forState:UIControlStateNormal];
}

- (void)handleTap:(UIGestureRecognizer *)recognizer
{
    NSLog(@"######### Photo tapped!");
    
    [self.delegate capturedContextDetailViewPhotoTapped:self];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    // FIX: more or less duplicate of what's in AudioPreviewViewController
    
    // TODO: check if what stopped was memo or ambient
    if ([player.url.path isEqualToString:self.capturedContext.memoFilePath] &&
        self.capturedContext.ambientAudioFileExists)
    {
        // Finished playing memo, so start playing ambient audio, if it exists
        NSError *error = nil;
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:self.capturedContext.ambientAudioFilePath] error:&error];
        audioPlayer.delegate = self;
        
        if (error)
        {
            NSLog(@"ERROR: CapturedContextDetailView: Could not start playing audio file at %@: %@", audioPlayer.url.path, error.localizedDescription);
            audioPlayer = nil;
            [self handleAudioPlaybackStopped];
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
        [self handleAudioPlaybackStopped];
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"ERROR: CapturedContextDetailView: Error playing audio file at %@: %@", player.url.path, error.localizedDescription);
    audioPlayer = nil;
    [self handleAudioPlaybackStopped];
}

@end
