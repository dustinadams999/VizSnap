//
//  AudioRecorder.h
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/07/30.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioQueue.h>
#import <AudioToolbox/AudioFile.h>

@class AudioRecorder;

@protocol AudioRecorderDelegate <NSObject>

- (void)audioRecorder:(AudioRecorder *)recorder finishedRecordingToFile:(NSString *)filepath;

@end

@interface AudioRecorder : NSObject

@property (nonatomic, readonly) BOOL isRecording;
@property (nonatomic, readonly) CGFloat averagePower;
@property (nonatomic, readonly) CGFloat peakPower;
@property (nonatomic, readonly) NSTimeInterval currentTime;

@property (nonatomic, assign) NSTimeInterval maxRecordingDuration;

@property (nonatomic, weak) id<AudioRecorderDelegate> delegate;

- (BOOL)startRecording:(NSString *)filePath;
- (void)stopRecordingAndKeepAudioFile:(BOOL)keepAudioFile;
- (void)pause;
- (BOOL)resume;

@end
