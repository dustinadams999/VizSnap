//
//  ContextCaptureHelper.h
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/08/07.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CapturedContext.h"
#import "CameraFrameCaptureHelper.h"

@class ContextCaptureHelper;

typedef void (^CaptureCompletionCallback)(ContextCaptureHelper *sender, BOOL success);
typedef void (^CaptureCommitCompletionCallback)(ContextCaptureHelper *sender, CapturedContext *commitedCapturedContext, BOOL success);


@interface ContextCaptureHelper : NSObject

@property (nonatomic, strong, readonly) CameraFrameCaptureHelper *cameraFrameCaptureHelper;

// If YES, either actively capturing or in midst of saving.
@property (nonatomic, readonly) BOOL isCapturingAmbientAudio;
@property (nonatomic, readonly) BOOL isCapturingMemoAudio;
@property (nonatomic, readonly) BOOL isCapturingPhoto;
@property (nonatomic, readonly) BOOL isCapturingPhodio;
//@property (nonatomic) BOOL isCapturingVideo;

@property (nonatomic, readonly) BOOL isCapturePaused;

@property (nonatomic, readonly) NSString *temporarilyCapturedAmbientAudioFilePath;
@property (nonatomic, readonly) NSString *temporarilyCapturedMemoAudioFilePath;
@property (nonatomic, readonly) UIImage *temporarilyCapturedImage;


- (BOOL)startAmbientAudioCapture;
- (void)stopAmbientAudioCaptureWithCompletion:(CaptureCompletionCallback)completionCallback;


- (BOOL)startMemoAudioCapture;
- (void)stopMemoAudioCaptureWithCompletion:(CaptureCompletionCallback)completionCallback;


- (BOOL)startPhotoCapture;
- (void)stopPhotoCapture; // synonymous to snap photo.


- (BOOL)startPhodioCapture; // same as startAmbientAudioCapture + startPhotoCapture
- (void)stopPhodioCaptureWithCompletion:(CaptureCompletionCallback)completionCallback; 


//- (BOOL)startVideoCapture;
//- (void)stopVideoCaptureWithCompletion:(CaptureCompletionCallback)completionCallback;


- (void)pauseCapture;
- (void)resumeCapture;

- (void)discardTemporaryCaptures;
- (void)discardTemporaryPhodioCapture;
- (void)discardTemporaryAmbientAudioCapture;
- (void)discardTemporaryMemoAudioCapture;
- (void)discardTemporaryPhotoCapture;

// Make sure the captures are stopped before calling this method
- (BOOL)commitCapturesToCapturedContext:(CapturedContext *)capturedContext;
- (BOOL)commitAmbientAudioCaptureToCapturedContext:(CapturedContext *)capturedContext;
- (BOOL)commitMemoAudioCaptureToCapturedContext:(CapturedContext *)capturedContext;
- (BOOL)commitPhotoCaptureToCapturedContext:(CapturedContext *)capturedContext;

//- (void)commitCaptureToCapturedContext:(CapturedContext *)capturedContext withCompletionCallback:(CaptureCommitCompletionCallback)completionCallback;

@end
