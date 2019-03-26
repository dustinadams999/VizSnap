//
//  CameraFrameCaptureManager.m
//  NewAppPrototype
//
//  Created by 原田 丞 on 12/07/05.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "CameraFrameCaptureHelper.h"
#import "Orientation.h"
#import "UIImage+Utilities.h"

@interface CameraFrameCaptureHelper () <AVCaptureFileOutputRecordingDelegate>

@end

@implementation CameraFrameCaptureHelper
{
    AVCaptureSession *photoCaptureSession;
    AVCaptureSession *movieCaptureSession;

    
    AVCaptureMovieFileOutput *movieFileOutput;
    
    
    UIView *parentViewForPreview;
    AVCaptureVideoPreviewLayer *photoCapturePreviewLayer;
    AVCaptureVideoPreviewLayer *movieCapturePreviewLayer;
}

@synthesize currentCIImage = _currentCIImage;
@synthesize isUsingFrontCamera = _isUsingFrontCamera;

+ (id)helperWithCamera:(uint)whichCamera
{
    CameraFrameCaptureHelper *helper = [[CameraFrameCaptureHelper alloc] initWithCamera:whichCamera];
    return helper;
}

- (id)init
{
    if (self = [self initWithCamera:kCameraBack])
    {
    }
    return self;
}

- (id)initWithCamera:(uint)whichCamera
{
    if (self = [super init])
    {
        NSError *error = nil;
        
        // Is a camera available
        if (![CameraFrameCaptureHelper numberOfCameras]) return nil;

        // Choose camera
        _isUsingFrontCamera = NO;
        if (whichCamera == kCameraFront && [CameraFrameCaptureHelper frontCameraAvailable])
        {
            _isUsingFrontCamera = YES;
        }
        
        // Retrieve selected camera
        AVCaptureDevice *cameraDevice = self.isUsingFrontCamera ? [CameraFrameCaptureHelper frontCamera] : [CameraFrameCaptureHelper backCamera];
        
        
        ////////////////////
        // Set up the photo capture
        
        // Create the capture device input for the above chosen camera
        AVCaptureDeviceInput *photoCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:cameraDevice error:&error];
        if (!photoCameraDeviceInput)
        {
            NSLog(@"ERROR: Couldn't create video capture device: %@", error.localizedDescription);
            return nil;
        }

        // Create the video data output for grabbing frames from camera.
        AVCaptureVideoDataOutput *videoDataCameraFrameOutput = [AVCaptureVideoDataOutput new];
        videoDataCameraFrameOutput.alwaysDiscardsLateVideoFrames = YES;
        [videoDataCameraFrameOutput setSampleBufferDelegate:self queue:dispatch_queue_create("com.ibm.research.tokyo.AR", NULL)];

        // Specify the pixel format setting for the video data output.
        NSDictionary *settings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey];
        videoDataCameraFrameOutput.videoSettings = settings;
        
        
        // Create the photo capture session
        photoCaptureSession = [AVCaptureSession new];
        [photoCaptureSession beginConfiguration];
        photoCaptureSession.sessionPreset = AVCaptureSessionPresetPhoto;

        // Add the camera device input
        if ([photoCaptureSession canAddInput:photoCameraDeviceInput])
        {
            [photoCaptureSession addInput:photoCameraDeviceInput];
        }
        else
        {
            NSLog(@"ERROR: Couldn't add camera device input");
        }

        // Add the video data output
        if ([photoCaptureSession canAddOutput:videoDataCameraFrameOutput])
        {
            [photoCaptureSession addOutput:videoDataCameraFrameOutput];
        }
        else
        {
            NSLog(@"ERROR: Couldn't add video data output");
        }

        [photoCaptureSession commitConfiguration];
        
        photoCapturePreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:photoCaptureSession];
        photoCapturePreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        
        
        ////////////////////
        // Set up the movie capture

        // Create the capture device input for the above chosen camera
        AVCaptureDeviceInput *movieCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:cameraDevice error:&error];
        if (!movieCameraDeviceInput)
        {
            NSLog(@"ERROR: Couldn't create video capture device: %@", error.localizedDescription);
            return nil;
        }
        
        // Create the movie file output
        movieFileOutput = [AVCaptureMovieFileOutput new];
        
        // Create movie capture session
        movieCaptureSession = [AVCaptureSession new];
        [movieCaptureSession beginConfiguration];
        movieCaptureSession.sessionPreset = AVCaptureSessionPresetHigh;
        
        // Add the camera device input
        if ([movieCaptureSession canAddInput:movieCameraDeviceInput])
        {
            [movieCaptureSession addInput:movieCameraDeviceInput];
        }
        else
        {
            NSLog(@"ERROR: Couldn't add video input");
        }

        // Add the movie file output
        if ([movieCaptureSession canAddOutput:movieFileOutput])
        {
            [movieCaptureSession addOutput:movieFileOutput];
        }
        else
        {
            NSLog(@"ERROR: Couldn't add movie file output");
        }
        
        [movieCaptureSession commitConfiguration];
        
        movieCapturePreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:movieCaptureSession];
        movieCapturePreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

    }
    return self;
}

- (void)dealloc
{
    NSLog(@"CaptureSessionManager: dealloc called");
    [photoCaptureSession stopRunning];
    photoCaptureSession = nil;

    [movieFileOutput stopRecording];
    movieFileOutput = nil;
    [movieCaptureSession stopRunning];
    movieCaptureSession = nil;
}

- (UIImage *)currentImage
{
    UIImageOrientation orientation = [Orientation currentImageOrientationUsingFrontCamera:self.isUsingFrontCamera shouldMirrorFlip:NO];
    return [UIImage imageWithCIImage:self.currentCIImage orientation:orientation];
}

#pragma mark - Public classs methods

+ (int)numberOfCameras
{
    return [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count;
}

+ (BOOL)backCameraAvailable
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in videoDevices)
        if (device.position == AVCaptureDevicePositionBack) return YES;
    return NO;
}

+ (BOOL)frontCameraAvailable
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in videoDevices)
        if (device.position == AVCaptureDevicePositionFront) return YES;
    return NO;
}

+ (AVCaptureDevice *)backCamera
{
    static AVCaptureDevice *backCamera = nil;
    if (backCamera == nil)
    {
        NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *device in videoDevices)
        {
            if (device.position == AVCaptureDevicePositionBack)
            {
                backCamera = device;
                break;
            }
        }
        if (backCamera == nil)
        {
            backCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        }

        if ([backCamera isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
        {
            NSError *error = nil;
            if ([backCamera lockForConfiguration:&error])
            {
                // FIX: doesn't seem to be working...
                [backCamera setFocusPointOfInterest:CGPointMake(0.5, 0.5)];
                [backCamera setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
                [backCamera unlockForConfiguration];
            }
            else
            {
                NSLog(@"ERROR: error failing to set focus mode on camera");
            }
        }
    }
    
    return backCamera;
}

+ (AVCaptureDevice *)frontCamera
{
    static AVCaptureDevice *frontCamera = nil;
    if (frontCamera == nil)
    {
        NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *device in videoDevices)
        {
            if (device.position == AVCaptureDevicePositionFront)
            {
                frontCamera = device;
                break;
            }
        }
        if (frontCamera == nil)
        {
            frontCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        }
        
        if ([frontCamera isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
        {
            NSError *error = nil;
            if ([frontCamera lockForConfiguration:&error])
            {
                // FIX: doesn't seem to be working...
                [frontCamera setFocusPointOfInterest:CGPointMake(0.5, 0.5)];
                [frontCamera setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
                [frontCamera unlockForConfiguration];
            }
            else
            {
                NSLog(@"ERROR: error failing to set focus mode on camera");
            }
        }
    }
    
    return frontCamera;
}

#pragma mark - Public instance methods

- (void)switchCameras
{
    if ([CameraFrameCaptureHelper numberOfCameras] <= 1) return;
    
    _isUsingFrontCamera = !self.isUsingFrontCamera;
    AVCaptureDevice *newDevice = self.isUsingFrontCamera ? [CameraFrameCaptureHelper frontCamera] : [CameraFrameCaptureHelper backCamera];
    
    [photoCaptureSession beginConfiguration];
    
    // Remove existing inputs
    for (AVCaptureInput *input in [photoCaptureSession inputs])
    {
        [photoCaptureSession removeInput:input];
    }
    
    // Change the input
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:newDevice error:nil];
    [photoCaptureSession addInput:captureInput];
    
    [photoCaptureSession commitConfiguration];
}

- (void)startCameraFrameCapture
{
    [photoCaptureSession startRunning];
}

- (BOOL)isCameraFrameCapturing
{
    return photoCaptureSession.isRunning;
}

- (void)stopCameraFrameCapture
{
    [photoCaptureSession stopRunning];
}

- (void)startRecordingVideoToFile:(NSString *)filepath
{
    NSLog(@"Stopping photo capture session");
    [photoCaptureSession stopRunning];
    NSLog(@"  Stopped photo capture session");
    
    
    // Swap out the preview layer
    if (parentViewForPreview != nil)
    {
        [photoCapturePreviewLayer removeFromSuperlayer];
        movieCapturePreviewLayer.frame = parentViewForPreview.bounds;
        [parentViewForPreview.layer insertSublayer:movieCapturePreviewLayer atIndex:0];
    }
    
    // Make sure the target file doesn't already exist.
    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath])
    {
        NSLog(@"Movie file already exists at %@. Attempting to delete.", filepath);
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:filepath error:&error];
        if (error != nil)
        {
            NSLog(@"ERROR: couldn't delete file at %@", filepath);
        }
    }
    NSLog(@"Starting movie capture session");
    [movieCaptureSession startRunning];
    NSLog(@"  Started movie capture session");
    [movieFileOutput startRecordingToOutputFileURL:[[NSURL alloc] initFileURLWithPath:filepath] recordingDelegate:self];
}

- (void)stopRecordingVideo
{
    [movieFileOutput stopRecording];
    NSLog(@"Stopping movie capture session");
    [movieCaptureSession stopRunning];
    NSLog(@"  Stopped movie capture session");

    // Swap out the preview layer
    if (parentViewForPreview != nil)
    {
        [movieCapturePreviewLayer removeFromSuperlayer];
        photoCapturePreviewLayer.frame = parentViewForPreview.bounds;
        [parentViewForPreview.layer insertSublayer:photoCapturePreviewLayer atIndex:0];
    }

    
    NSLog(@"Starting photo capture session");
    [photoCaptureSession startRunning];
    NSLog(@"  Started photo capture session");
}


- (void)embedPreviewInView:(UIView *)aView
{
    if (!photoCaptureSession) return;
    
    parentViewForPreview = aView;

    // FIX: choose the appropriate layer based on which mode we're in
    photoCapturePreviewLayer.frame = aView.bounds;
    [aView.layer insertSublayer:photoCapturePreviewLayer atIndex:0];
}

- (UIView *)previewWithFrame:(CGRect)aFrame
{
    if (!photoCaptureSession) return nil;
    
    UIView *view = [[UIView alloc] initWithFrame:aFrame];
    [self embedPreviewInView:view];
    
    return view;
}

- (AVCaptureVideoPreviewLayer *)previewInView:(UIView *)view
{
    for (CALayer *layer in view.layer.sublayers)
    {
        if ([layer isKindOfClass:[AVCaptureVideoPreviewLayer class]])
        {
            return (AVCaptureVideoPreviewLayer *)layer;
        }
    }
    return nil;
}

- (void)layoutPreviewInView:(UIView *)aView
{
    AVCaptureVideoPreviewLayer *layer = [self previewInView:aView];
    if (!layer) return;
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    CATransform3D transform = CATransform3DIdentity;
    if (orientation == UIDeviceOrientationPortrait) ;
    else if (orientation == UIDeviceOrientationLandscapeLeft)
        transform = CATransform3DMakeRotation(-M_PI_2, 0.0f, 0.0f, 1.0f);
    else if (orientation == UIDeviceOrientationLandscapeRight)
        transform = CATransform3DMakeRotation(M_PI_2, 0.0f, 0.0f, 1.0f);
    else if (orientation == UIDeviceOrientationPortraitUpsideDown)
        transform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
    
    layer.transform = transform;
    layer.frame = aView.frame;
}

#pragma mark - Private utility methods

- (UIImageOrientation)currentImageOrientation
{
    return [Orientation currentImageOrientationUsingFrontCamera:self.isUsingFrontCamera shouldMirrorFlip:NO];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    @autoreleasepool {
        // Transfer into a Core Video image buffer
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        
        // Create a Core Image result
        CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
        
        _currentCIImage = [[CIImage alloc] initWithCVPixelBuffer:imageBuffer options:(__bridge_transfer NSDictionary *)attachments];
    }
}

#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    NSLog(@"Successfully recorded video to %@", outputFileURL.path);
}

@end
