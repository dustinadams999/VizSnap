//
//  CameraFrameCaptureManager.h
//  NewAppPrototype
//
//  Created by 原田 丞 on 12/07/05.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>


enum {
	kCameraNone = -1,
	kCameraFront,
    kCameraBack,
} availableCameras;

@interface CameraFrameCaptureHelper : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, assign) BOOL detectFaces;
@property (nonatomic, readonly) int currentNumFacesDetected;
@property (nonatomic, strong) CIImage *currentCIImage;
@property (nonatomic, readonly) UIImage *currentImage;
@property (nonatomic, readonly) BOOL isUsingFrontCamera;

+ (int)numberOfCameras;
+ (BOOL)backCameraAvailable;
+ (BOOL)frontCameraAvailable;
+ (AVCaptureDevice *)backCamera;
+ (AVCaptureDevice *)frontCamera;
+ (id)helperWithCamera:(uint)whichCamera;

- (void)switchCameras;

- (void)startCameraFrameCapture;
- (BOOL)isCameraFrameCapturing;
- (void)stopCameraFrameCapture;

- (void)embedPreviewInView:(UIView *)aView;
- (AVCaptureVideoPreviewLayer *)previewInView:(UIView *)view;
- (void)layoutPreviewInView:(UIView *)aView;

@end
