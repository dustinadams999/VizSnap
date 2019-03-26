//
//  VolumeButtonListener.m
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/07/27.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "VolumeButtonListener.h"
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>

@interface VolumeButtonListener ()

@property (nonatomic, assign) float launchVolume;

-(void)initializeVolumeButtonStealer;
-(void)volumeDown;
-(void)volumeUp;
-(void)applicationCameBack;
-(void)applicationWentAway;

@end

@implementation VolumeButtonListener {
    BOOL isStarted;
    
    BOOL hadToLowerVolume;
    BOOL hadToRaiseVolume;
    BOOL justEnteredForeground;
    
    id applicationWillResignActiveObserver;
    id applicationDidBecomeActiveObserver;
    id applicationWillEnterForegroundObserver;
    
    MPVolumeView *volumeView;
}

@synthesize delegate;
@synthesize launchVolume;

void volumeListenerCallback (
                             void                      *inClientData,
                             AudioSessionPropertyID    inID,
                             UInt32                    inDataSize,
                             const void                *inData
                             );
void volumeListenerCallback (
                             void                      *inClientData,
                             AudioSessionPropertyID    inID,
                             UInt32                    inDataSize,
                             const void                *inData
                             ){
    const float *volumePointer = inData;
    float volume = *volumePointer;
    
    
    if( volume > [(VolumeButtonListener*)inClientData launchVolume] )
    {
        [(VolumeButtonListener*)inClientData volumeUp];
    }
    else if( volume < [(VolumeButtonListener*)inClientData launchVolume] )
    {
        [(VolumeButtonListener*)inClientData volumeDown];
    }
}

-(void)volumeDown
{
    AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_CurrentHardwareOutputVolume, volumeListenerCallback, self);
    
    [[MPMusicPlayerController applicationMusicPlayer] setVolume:launchVolume];
    
    [self performSelector:@selector(initializeVolumeButtonStealer) withObject:self afterDelay:0.05];
    
    [self.delegate volumeButtonListenerVolumeDownPressed:self];
}

-(void)volumeUp
{
    AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_CurrentHardwareOutputVolume, volumeListenerCallback, self);
    
    [[MPMusicPlayerController applicationMusicPlayer] setVolume:launchVolume];
    
    [self performSelector:@selector(initializeVolumeButtonStealer) withObject:self afterDelay:0.05];
    
    [self.delegate volumeButtonListenerVolumeUpPressed:self];
}

-(void)applicationCameBack
{
    if (isStarted) {
        [self initializeVolumeButtonStealer];
        launchVolume = [[MPMusicPlayerController applicationMusicPlayer] volume];
        hadToLowerVolume = launchVolume == 1.0;
        hadToRaiseVolume = launchVolume == 0.0;
        if( hadToLowerVolume )
        {
            [[MPMusicPlayerController applicationMusicPlayer] setVolume:0.9];
            launchVolume = 0.9;
        }
        
        if( hadToRaiseVolume )
        {
            [[MPMusicPlayerController applicationMusicPlayer] setVolume:0.1];
            launchVolume = 0.1;
        }
    }
}

-(void)applicationWentAway
{
    if (isStarted) {
        AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_CurrentHardwareOutputVolume, volumeListenerCallback, self);
        
        if( hadToLowerVolume )
        {
            [[MPMusicPlayerController applicationMusicPlayer] setVolume:1.0];
        }
        
        if( hadToRaiseVolume )
        {
            [[MPMusicPlayerController applicationMusicPlayer] setVolume:0.0];
        }
    }
}

- (void)start
{
    if (isStarted == NO) {
        AudioSessionInitialize(NULL, NULL, NULL, NULL);
        AudioSessionSetActive(YES);
        
        launchVolume = [[MPMusicPlayerController applicationMusicPlayer] volume];
        hadToLowerVolume = launchVolume == 1.0;
        hadToRaiseVolume = launchVolume == 0.0;
        justEnteredForeground = NO;
        if( hadToLowerVolume )
        {
            [[MPMusicPlayerController applicationMusicPlayer] setVolume:0.9];
            launchVolume = 0.9;
            
        }
        
        if( hadToRaiseVolume )
        {
            [[MPMusicPlayerController applicationMusicPlayer] setVolume:0.1];
            launchVolume = 0.1;
        }
        
        CGRect frame = CGRectMake(0, -100, 10, 0);
        volumeView = [[[MPVolumeView alloc] initWithFrame:frame] autorelease];
        [volumeView sizeToFit];
        [[[[UIApplication sharedApplication] windows] objectAtIndex:0] addSubview:volumeView];
        
        [self initializeVolumeButtonStealer];
        
        
        applicationWillResignActiveObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification){
            [self applicationWentAway];
        }];
        
        
        applicationDidBecomeActiveObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification){
            if( ! justEnteredForeground )
            {
                [self applicationCameBack];
            }
            justEnteredForeground = NO;
        }];
        
        
        applicationWillEnterForegroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification){
            AudioSessionInitialize(NULL, NULL, NULL, NULL);
            AudioSessionSetActive(YES);
            justEnteredForeground = YES;
            [self applicationCameBack];
            
            
        }];
        
        isStarted = YES;
    }
}

- (void)stop
{
    if (isStarted) {
        AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_CurrentHardwareOutputVolume, volumeListenerCallback, self);
        
        if( hadToLowerVolume )
        {
            [[MPMusicPlayerController applicationMusicPlayer] setVolume:1.0];
        }
        
        if( hadToRaiseVolume )
        {
            [[MPMusicPlayerController applicationMusicPlayer] setVolume:0.0];
        }
        
        [[NSNotificationCenter defaultCenter] removeObserver:applicationWillResignActiveObserver];
        [[NSNotificationCenter defaultCenter] removeObserver:applicationDidBecomeActiveObserver];
        [[NSNotificationCenter defaultCenter] removeObserver:applicationWillEnterForegroundObserver];
        
        [volumeView removeFromSuperview];
        volumeView = nil;
        
        isStarted = NO;
    }
}

-(void)initializeVolumeButtonStealer
{
    AudioSessionAddPropertyListener(kAudioSessionProperty_CurrentHardwareOutputVolume, volumeListenerCallback, self);
}

@end