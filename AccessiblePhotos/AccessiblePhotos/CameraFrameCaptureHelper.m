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

@property (nonatomic) int currentNumFacesDetected;

@end

@implementation CameraFrameCaptureHelper
{
    AVCaptureSession *photoCaptureSession;
    AVCaptureSession *movieCaptureSession;

    AVCaptureMovieFileOutput *movieFileOutput;
    
    UIView *parentViewForPreview;
    AVCaptureVideoPreviewLayer *photoCapturePreviewLayer;
    AVCaptureVideoPreviewLayer *movieCapturePreviewLayer;
    
    CIDetector *faceDetector;
}

@synthesize detectFaces;
@synthesize currentNumFacesDetected;
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
        
        // Get microphone device
        AVCaptureDevice *microphoneDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        
        AVCaptureDeviceInput *microphoneDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:microphoneDevice error:&error];
        if (!microphoneDeviceInput)
        {
            NSLog(@"ERROR: Couldn't create microphone device input: %@", error.localizedDescription);
        }
        
        ////////////////////
        // Set up the photo capture
        
        // Create the capture device input for the above chosen camera
        AVCaptureDeviceInput *photoCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:cameraDevice error:&error];
        if (!photoCameraDeviceInput)
        {
            NSLog(@"ERROR: Couldn't create video feed capture device: %@", error.localizedDescription);
            return nil;
        }

        //This section is OK because it allows in the video streaming device
        
        // Create the video feed data output for grabbing frames from camera.
        AVCaptureVideoDataOutput *videoDataCameraFrameOutput = [AVCaptureVideoDataOutput new];
        videoDataCameraFrameOutput.alwaysDiscardsLateVideoFrames = YES;
        [videoDataCameraFrameOutput setSampleBufferDelegate:self queue:dispatch_queue_create("com.ibm.research.tokyo.ar", NULL)];

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
        
        // Initialize the photo preview layer
        photoCapturePreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:photoCaptureSession];
        photoCapturePreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        
        [self setupCameraDevice:cameraDevice];
        

        //////////////////////////////////////////////
        // Set up face detector.
        NSDictionary *faceDetectorOptions = [NSDictionary dictionaryWithObjectsAndKeys: CIDetectorAccuracyLow, CIDetectorAccuracy, nil];
        faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil
                                          options:faceDetectorOptions];
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
    
    [self setupCameraDevice:newDevice];
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

- (void)setupCameraDevice:(AVCaptureDevice *)cameraDevice
{
    //////////////////////////////////////////////
    // Set up autofocus.
    if ([cameraDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
    {
        NSError *error = nil;
        if ([cameraDevice lockForConfiguration:&error])
        {
            // FIX: doesn't seem to be working...
            //                [cameraDevice setFocusPointOfInterest:CGPointMake(0.5, 0.5)];
            [cameraDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            [cameraDevice unlockForConfiguration];
        }
        else
        {
            NSLog(@"ERROR: error failing to set focus mode on camera");
        }
    }
    
    //////////////////////////////////////////////
    // Set up autowhitebalance.
    if ([cameraDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance])
    {
        NSError *error = nil;
        if ([cameraDevice lockForConfiguration:&error])
        {
            [cameraDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
            [cameraDevice unlockForConfiguration];
        }
        else
        {
            NSLog(@"ERROR: error failing to set white balance mode on camera");
        }
    }
    
    //////////////////////////////////////////////
    // Set up auto-exposure.
    if ([cameraDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
    {
        NSError *error = nil;
        if ([cameraDevice lockForConfiguration:&error])
        {
            [cameraDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            [cameraDevice unlockForConfiguration];
        }
        else
        {
            NSLog(@"ERROR: error failing to set exposure mode on camera");
        }
    }
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
        
        if (self.detectFaces)
        {
            uint orientation = [Orientation detectorEXIFUsingFrontCamera:self.isUsingFrontCamera shouldMirrorFlip:NO];
            NSDictionary *imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:orientation] forKey:CIDetectorImageOrientation];
            NSArray *faces = [faceDetector featuresInImage:_currentCIImage options:imageOptions];
            
            if (self.currentNumFacesDetected != faces.count)
            {
                self.currentNumFacesDetected = faces.count;
            }
        }
    }
}


#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    //COMMENTED OUT BY DUSTIN 3/16/2015 IN ORDER TO REMOVE ALL TRACES OF VIDEO CAPTURE IN ORDER TO SUBMIT TO APP STORE
    //NSLog(@"Successfully recorded video to %@", outputFileURL.path);
}

@end
