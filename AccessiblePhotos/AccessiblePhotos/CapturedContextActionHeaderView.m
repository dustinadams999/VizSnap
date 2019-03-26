//
//  CapturedContextActionHeaderView.m
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/08/01.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "CapturedContextActionHeaderView.h"
#import <AVFoundation/AVFoundation.h>

@interface CapturedContextActionHeaderView () <AVAudioPlayerDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIButton *playAudioButton;
@property (nonatomic, weak) IBOutlet UILabel *recordingLengthLabel;

- (IBAction)playAudioButtonTapped:(id)sender;
- (IBAction)tagToSendLaterButtonTapped:(id)sender;

@end

@implementation CapturedContextActionHeaderView
{
    AVAudioPlayer *audioPlayer;
    BOOL isPlayingAudio;
}

@synthesize capturedContext = _capturedContext;
@synthesize delegate;
@synthesize imageView;
@synthesize playAudioButton;
@synthesize recordingLengthLabel;

- (void)setCapturedContext:(CapturedContext *)capturedContext
{
    _capturedContext = capturedContext;
    if (self.imageView)
    {
        self.imageView.image = self.capturedContext.uiImage;
    }
    
    NSError *error = nil;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:self.capturedContext.ambientAudioFilePath] error:&error];
    
    if (error)
    {
        NSLog(@"ERROR: CapturedContextActionHeaderView: failed to initialize audio player for %@: %@", self.capturedContext.ambientAudioFilePath, error.localizedDescription);
        audioPlayer = nil;
    }
    else
    {
        audioPlayer.delegate = self;
        [audioPlayer prepareToPlay];
        
        self.recordingLengthLabel.text = [NSString stringWithFormat:@"Recording length: %.1f sec", audioPlayer.duration];
    }
}

- (void)playAudioButtonTapped:(id)sender
{
    if (isPlayingAudio)
    {
        [self stopAudio];
    }
    else
    {
        [self startAudio];
    }
}

- (void)tagToSendLaterButtonTapped:(id)sender
{
    [self.delegate capturedContextActionHeaderViewTagToSendLater:self];
}

- (void)startAudio
{
    if (isPlayingAudio == NO)
    {
        if (audioPlayer.isPlaying == NO)
        {
            if ([audioPlayer play] == NO)
            {
                NSLog(@"ERROR: CapturedContextActionHeaderView: failed to start playing audio for %@", audioPlayer.url.path);
                return;
            }
        }
        [self.playAudioButton setTitle:@"Stop playing" forState:UIControlStateNormal];
        isPlayingAudio = YES;
    }
}

- (void)stopAudio
{
    if (isPlayingAudio == YES)
    {
        if (audioPlayer.isPlaying == YES)
        {
            [audioPlayer stop];
        }
        [self.playAudioButton setTitle:@"Play recorded audio" forState:UIControlStateNormal];
        isPlayingAudio = NO;
    }
}

- (void)setRecordingLength:(double)duration
{
    self.recordingLengthLabel.text = [NSString stringWithFormat:@"Recording length: %.1fs", (int)duration];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self stopAudio];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    [self stopAudio];
}

@end
