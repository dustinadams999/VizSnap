//
//  AudioSessionManager.h
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/08/15.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    kAudioSessionModeNoAudio,
    kAudioSessionModeRecording,
    kAudioSessionModePlayback
} AudioSessionMode;

@interface AudioSessionManager : NSObject

@property (nonatomic, assign) AudioSessionMode currentMode;
@property (nonatomic, assign) BOOL enableRecordingViaBluetooth;

+ (AudioSessionManager *)sharedManager;

@end
