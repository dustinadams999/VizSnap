//
//  ContextCaptureViewController_Protected.h
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/07/24.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "ContextCaptureViewController.h"

@interface ContextCaptureViewController ()

@property (nonatomic, strong, readonly) CameraFrameCaptureHelper *cameraFrameCaptureHelper;
@property (nonatomic, strong, readonly) CapturedContext *capturedContext;
@property (nonatomic, strong, readonly) UIImage *capturedCameraFrame;

- (void)startCameraFrameCapture;
- (void)startAudioCapture;
- (void)startVoiceMemoCapture;
- (void)stopCameraFrameCapture;
- (void)stopAudioCapture;
- (void)stopVoiceMemoCapture;

- (void)captureCameraFrameAndStopCameraFrameCapture:(BOOL)stopCameraFrameCapture stopAudioCapture:(BOOL)stopAudioCapture;

- (void)discardCapturedContext;
- (void)saveCapturedContext;
- (void)justSaveCapturedContextToAlbum;
- (void)saveCapturedContextAndTagToBeSent;
- (void)saveCapturedContextAndSendToGroup:(NSString *)group;

- (void)exitCapture;

@end
