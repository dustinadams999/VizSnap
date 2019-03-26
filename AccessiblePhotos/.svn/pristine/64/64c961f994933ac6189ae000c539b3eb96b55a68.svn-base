//
//  AudioTableCell.m
//  AccessiblePhotos
//
//  Created by Adams Dustin on 7/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AudioTableCell.h"

@interface AudioTableCell ()

@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;

-(IBAction)pressPlay;

@end

@implementation AudioTableCell
{
    BOOL isPlayingAudio;
    int rowIndex;
    int totalRowCount;
}

@synthesize capturedContext = _capturedContext;
@synthesize rowIndex;
@synthesize totalRowCount;
@synthesize timeLabel;
@synthesize playButton;
@synthesize imageView;
@synthesize delegate;

- (void)setCapturedContext:(CapturedContext *)capturedContext
{
    _capturedContext = capturedContext;
    
    if (self.capturedContext != nil)
    {
        if (self.capturedContext.ambientAudioFileExists == NO && self.capturedContext.memoAudioFileExists == NO)
        {
            self.playButton.hidden = YES;
        }
        else
        {
            self.playButton.hidden = NO;
        }
    
        if (self.capturedContext.uiImage != nil)
        {
            self.imageView.image = self.capturedContext.uiImage;
        }
        else
        {
            self.imageView.image = nil;
        }
    }
}

- (void)setCapturedContext:(CapturedContext *)capturedContext rowIndex:(int)aRowIndex totalRowCount:(int)aTotalRowCount
{
    self.capturedContext = capturedContext;
    self->rowIndex = aRowIndex;
    self->totalRowCount = aTotalRowCount;
    
    self.timeLabel.text = [NSDateFormatter localizedStringFromDate:self.capturedContext.timestamp dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];

    NSString *accessibilityLabel = @"";
        
    if (self.capturedContext.ambientAudioFileExists == NO && self.capturedContext.memoAudioFileExists == NO)
    {
        accessibilityLabel = [NSString stringWithFormat:@"%d of %d. No audio. Taken on %@", (rowIndex + 1), totalRowCount, [NSDateFormatter localizedStringFromDate:self.capturedContext.timestamp dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterFullStyle]];
        if (self.capturedContext.placemark != nil)
        {
            accessibilityLabel = [accessibilityLabel stringByAppendingFormat:@" at %@, %@, %@", self.capturedContext.placemark.country, self.capturedContext.placemark.administrativeArea, self.capturedContext.placemark.subLocality];
        }
        else
        {
            accessibilityLabel = [accessibilityLabel stringByAppendingString:@" at unknown location"];
        }
    }

    self.accessibilityLabel = accessibilityLabel;
}

//- (void)setTimestampLabel:(NSString *)timestampLabel
//{
//    _timestampLabel = timestampLabel;
//    
//    self.timeLabel.text = self.timestampLabel;
//    
//    // FIX: remove the following to prevent VoiceOver from speaking over
//    // the audio playback
//    //self.accessibilityLabel = self.timestampLabel;
//}

-(void)pressPlay
{
    if (!isPlayingAudio)
    {
        [self.playButton setTitle:@"Stop" forState:UIControlStateNormal];
        [self.delegate audioTableCell:self startPlayingAudioOfCapturedContext:self.capturedContext];
        isPlayingAudio = YES;
    }
    else
    {
        [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
        [self.delegate audioTableCell:self stopPlayingAudioOfCapturedContext:self.capturedContext];
        isPlayingAudio = NO;
    }
}

- (void)accessibilityElementDidBecomeFocused
{
    if (self.capturedContext.memoAudioFileExists == YES || self.capturedContext.ambientAudioFileExists == YES)
    {
        [self.delegate audioTableCell:self startPlayingAudioOfCapturedContext:self.capturedContext];
    }
}

- (void)accessibilityElementDidLoseFocus
{
    if (self.capturedContext.memoAudioFileExists == YES || self.capturedContext.ambientAudioFileExists == YES)
    {
        [self.delegate audioTableCell:self stopPlayingAudioOfCapturedContext:self.capturedContext];
    }
}

- (void)audioStopped
{
    if (isPlayingAudio)
    {
        [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
        isPlayingAudio = NO;
    }
}

- (void)audioFinishedPlaying
{
    [self audioStopped];
    
    NSString *captureDetails = [NSString stringWithFormat:@"%d of %d. Taken on %@", (rowIndex + 1), totalRowCount, [NSDateFormatter localizedStringFromDate:self.capturedContext.timestamp dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterFullStyle]];
    if (self.capturedContext.placemark != nil)
    {
        captureDetails = [captureDetails stringByAppendingFormat:@" at %@, %@, %@", self.capturedContext.placemark.country, self.capturedContext.placemark.administrativeArea, self.capturedContext.placemark.subLocality];
    }
    else
    {
        captureDetails = [captureDetails stringByAppendingString:@" at unknown location"];
    }
    
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, captureDetails);
}

@end
