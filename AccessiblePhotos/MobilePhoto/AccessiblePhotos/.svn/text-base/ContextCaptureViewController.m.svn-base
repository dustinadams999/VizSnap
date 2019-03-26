//
//  ImageCaptureViewController.m
//  NewAppPrototype
//
//  Created by 原田 丞 on 12/07/05.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "ContextCaptureViewController.h"
#import "ContextCaptureViewController_Protected.h"
#import "CapturedContextManager.h"
#import "UserManager.h"
#import "WebRequestManager.h"

@interface ContextCaptureViewController() <AVAudioRecorderDelegate>

@end

@implementation ContextCaptureViewController
{
    AVAudioRecorder *audioRecorder;
    AVAudioRecorder *memoRecorder;
    AVAudioPlayer *cameraShutterPlayer;
    
    NSString *temporaryAudioFilePath;
    NSString *temporaryMemoFilePath;
    
    id applicationWillResignActiveObserver;
    id applicationDidEnterBackgroundObserver;
    id applicationWillEnterForegroundObserver;
    id applicationDidBecomeActiveObserver;
    
    BOOL imageNotYetCaptured;
    BOOL savingAudioFile;
    BOOL restartAudioRecordingAfterSaveCompletes;
    BOOL didRecordMemo;
    
    BOOL isUsingFrontCamera;
}

NSString *const kTemporaryAudioFilename = @"tempAudioRecording.caf";
NSString *const kTemporaryMemoFilename = @"tempAudioRecording_memo.caf";

@synthesize cameraFrameCaptureHelper = _cameraFrameCaptureHelper;
@synthesize capturedContext = _capturedContext;
@synthesize capturedCameraFrame = _capturedCameraFrame;
@synthesize delegate;

- (void)awakeFromNib
{
    NSLog(@"ImageCaptureViewController: awakeFromNib called");
    [super awakeFromNib];
    
    temporaryAudioFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:kTemporaryAudioFilename];
    temporaryMemoFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:kTemporaryMemoFilename];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Camera view";

    didRecordMemo = FALSE;
    imageNotYetCaptured = TRUE;

    
    //////////////////////////////////////////////
    // Set up the capture manager for grabbing image frames from the camera.
    NSLog(@"######## initializing capture manager");
    _cameraFrameCaptureHelper = [CameraFrameCaptureHelper new];
    NSLog(@"######## initialized capture manager");
    
    // Set up the view layer to show the live video stream from the camera.
    [self.cameraFrameCaptureHelper embedPreviewInView:self.view];
    
    
    //////////////////////////////////////////////
    // Set up the audio player for playing the camera shutter sound.
    NSURL *url = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"72714__horsthorstensen__shutter-photo" ofType:@"caf"]];
    NSError *error = nil;
    NSLog(@"######## allocating audio player");
    cameraShutterPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    NSLog(@"######## allocated audio player");
    if (cameraShutterPlayer == nil)
    {
        NSLog(@"audioPlayer error: %@", [error description]);
    }
    else
    {
        NSLog(@"######## preparing audio player");
        [cameraShutterPlayer prepareToPlay];
        NSLog(@"######## prepared audio player");
    }
    
    
    //////////////////////////////////////////////
    // Set up the audio recorder.
    error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error)
    {
        NSLog(@"Audio session error: Unable to set audio session category: %@", [error localizedDescription]);
    }
    
    error = nil;
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (error)
    {
        NSLog(@"Audio session error: Unable to set active: %@", [error localizedDescription]);
    }
    
    error = nil;
    NSDictionary *recordSettings = [NSDictionary 
                                    dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:AVAudioQualityMin],
                                    AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16], 
                                    AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: 2], 
                                    AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:44100.0], 
                                    AVSampleRateKey,
                                    nil];
    audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:temporaryAudioFilePath] settings:recordSettings error:&error];
    
    if (error)
    {
        NSLog(@"Audio recorder error: %@", [error localizedDescription]);
        audioRecorder = nil;
    }
    else
    {
        audioRecorder.delegate = self;
        if ([audioRecorder prepareToRecord] == NO)
        {
            NSLog(@"ContextCaptureViewController: audioRecorder prepareToRecord failed.");
            audioRecorder = nil;
        }
    }
    
    //////////////////////////////////////////////
    // Set up the memo audio recorder.
    error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error)
    {
        NSLog(@"Audio session error: Unable to set audio session category: %@", [error localizedDescription]);
    }
    
    error = nil;
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (error)
    {
        NSLog(@"Audio session error: Unable to set active: %@", [error localizedDescription]);
    }
    
    error = nil;
    
    memoRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:temporaryMemoFilePath] settings:recordSettings error:&error];
    
    if (error)
    {
        NSLog(@"Audio recorder error: %@", [error localizedDescription]);
        memoRecorder = nil;
    }
    else
    {
        memoRecorder.delegate = self;
        if ([memoRecorder prepareToRecord] == NO)
        {
            NSLog(@"ContextCaptureViewController: audioRecorder prepareToRecord failed.");
            memoRecorder = nil;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    [self startCameraFrameCapture];

    //////////////////////////////////////////////
    // Register to observe application notifications
    applicationWillResignActiveObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"com.ibm.research.tokyo.AccessiblePhotos.ApplicationWillResignActive" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note)
    {
        [self handleApplicationWillResignActive];
    }];
    applicationDidEnterBackgroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"com.ibm.research.tokyo.AccessiblePhotos.ApplicationDidEnterBackground" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note)
    {
        [self handleApplicationDidEnterBackground];
    }];
    applicationWillEnterForegroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"com.ibm.research.tokyo.AccessiblePhotos.ApplicationWillEnterForegroundObserver" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note)
    {
        [self handleApplicationWillEnterForeground];
    }];
    applicationDidBecomeActiveObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"com.ibm.research.tokyo.AccessiblePhotos.ApplicationDidBecomeActive" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note)
    {
        [self handleApplicationDidBecomeActive];
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [UIApplication sharedApplication].statusBarHidden = NO;

    [self stopCameraFrameCapture];

    [[NSNotificationCenter defaultCenter] removeObserver:applicationWillResignActiveObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:applicationDidEnterBackgroundObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:applicationWillEnterForegroundObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:applicationDidBecomeActiveObserver];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self stopAudioCapture];
    [self stopCameraFrameCapture];

    // FIX: do we need to do this elsewhere?
    _cameraFrameCaptureHelper = nil;

    cameraShutterPlayer = nil;
    audioRecorder = nil;
    memoRecorder = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Public instance methods

- (void)restartCapture
{
    [self stopAudioCapture];
    [self stopCameraFrameCapture];
    
    _capturedContext = nil;
    _capturedCameraFrame = nil;
    
    [self startAudioCapture];
    [self startCameraFrameCapture];
    imageNotYetCaptured = TRUE;
}

#pragma mark - Private instance methods

- (void)handleApplicationWillResignActive
{
    NSLog(@"ImageCaptureViewController: app willResignActive");
    
    //        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Pausing capture");
    // TODO?
}

- (void)handleApplicationDidEnterBackground
{
    NSLog(@"ImageCaptureViewController: app didEnterBackground");
    
    // Stop capture
    [self stopAudioCapture];
    [self stopCameraFrameCapture];
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Stopping capture");
}

- (void)handleApplicationWillEnterForeground
{
    NSLog(@"ImageCaptureViewController: app willEnterForegroundObserver");
    
    // Restart capture
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Restarting capture");
    [self restartCapture];
}

- (void)handleApplicationDidBecomeActive
{
    NSLog(@"ImageCaptureViewController: app didBecomeActive");
    
    // Restart capture (or resume if we hadn't stopped)
    //        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Restarting capture");
    // TODO?
}

- (void)startCameraFrameCapture
{
    NSLog(@"######## starting capture");
    [self.cameraFrameCaptureHelper startCameraFrameCapture];
    NSLog(@"######## started capture");
}

- (void)startAudioCapture
{
    NSLog(@"StartAudioCapture called: isRecording = %d", audioRecorder.isRecording);
    if (audioRecorder.isRecording == NO)
    {
        if (savingAudioFile)
        {
            NSLog(@"  audioRecorder is currently saving the audio file, so scheduling audio capture to be started after file finishes saving.");
            restartAudioRecordingAfterSaveCompletes = YES;
            return;
        }
        
        NSLog(@"Starting audio capture");
        if ([audioRecorder record] == NO)
        {
            NSLog(@"ContextCaptureViewController: startAudioCapture: record failed.");
            audioRecorder = nil;
            return;
        }
        // Create a new CapturedContext to represent the moment this camera frame was captured.
        // FIX: be careful: make sure this doesn't get called _after_ the image is captured,
        // otherwise the path to the image will be lost... unless we keep the image also in a temp file.
        _capturedContext = [CapturedContext new];
        NSLog(@" audio capture started: isRecording = %d", audioRecorder.isRecording);
    }
}

- (void)startVoiceMemoCapture
{
    //if the image has not yet been captured, then go ahead and capture the image
    if (imageNotYetCaptured)
    {
        [self captureCameraFrameAndStopCameraFrameCapture:YES stopAudioCapture:YES];
    }

    [memoRecorder record];
    NSLog(@"Starting memo recording");
}

- (void)stopCameraFrameCapture
{
    [self.cameraFrameCaptureHelper stopCameraFrameCapture];
    imageNotYetCaptured = TRUE;
}

- (void)stopAudioCapture
{
    NSLog(@"StopAudioCapture called: isRecording = %d", audioRecorder.isRecording);
    if (audioRecorder.isRecording)
    {
        NSLog(@"Stopping audio capture");
        savingAudioFile = YES;
        [audioRecorder stop];
        NSLog(@" audio capture stopped: isRecording = %d", audioRecorder.isRecording);
    }
    if (memoRecorder.isRecording)
    {
        NSLog(@"Stopping audio capture");
        [memoRecorder stop];
        NSLog(@" audio capture stopped: isRecording = %d", memoRecorder.isRecording);
        didRecordMemo = FALSE;
    }
}

- (void)stopVoiceMemoCapture
{
    if (memoRecorder.isRecording)
    {
        [memoRecorder stop];
    }
    NSLog(@"Stopping memo recording");
    didRecordMemo = TRUE;//this will have to go after the ambient recording is stopped  
}

// If we need to use StillCamera capture:
//- (void)captureCameraFrameAndStopCameraFrameCapture:(BOOL)stopCameraFrameCapture stopAudioCapture:(BOOL)stopAudioCapture
//{
//    if (stopAudioCapture)
//    {
//        [self stopAudioCapture];
//    }
//    
//    [self.cameraFrameCaptureHelper captureCameraFrameWithCallback:^(UIImage *image)
//    {
//        NSLog(@"####### captured image");
//        
//        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
//        [imageData writeToFile:[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"test.jpg"] atomically:YES];
//        
//        // Create a new CapturedContext to represent the moment this camera frame was captured.
//        _capturedContext = [CapturedContext new];
//        imageNotYetCaptured = FALSE;
//    }];
//}

- (void)captureCameraFrameAndStopCameraFrameCapture:(BOOL)stopCameraFrameCapture stopAudioCapture:(BOOL)stopAudioCapture
{
    CIImage *currentCIImage = [self.cameraFrameCaptureHelper currentCIImage];

    if (stopCameraFrameCapture)
    {
        [self stopCameraFrameCapture];
    }
    if (stopAudioCapture)
    {
        [self stopAudioCapture];
    }
        
    [cameraShutterPlayer play];

    // Convert the current camera frame into an UIImage and store it.
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef ref = [context createCGImage:currentCIImage fromRect:currentCIImage.extent];
    _capturedCameraFrame = [UIImage imageWithCGImage:ref scale:0.5 orientation:UIImageOrientationRight];
    CGImageRelease(ref);
    
    // Create a new CapturedContext to represent the moment this camera frame was captured.
    _capturedContext = [CapturedContext new];
    imageNotYetCaptured = FALSE;
}


- (void)discardCapturedContext
{
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Discarding captured photo.");
    [self restartCapture];
}

- (void)saveCapturedContext
{
    if (self.capturedContext != nil)
    {
        // Move the audio file over to the appropriate path
        [self stopAudioCapture];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:temporaryAudioFilePath] == NO)
        {
            NSLog(@"Error: temporary audio file does not exist at %@", temporaryAudioFilePath);
        }
        
        NSError *error;
        if (![[NSFileManager defaultManager] moveItemAtPath:temporaryAudioFilePath toPath:self.capturedContext.audioFilePath error:&error])
        {
            NSLog(@"Error moving file from %@ to %@: %@", temporaryAudioFilePath, self.capturedContext.audioFilePath, [error localizedDescription]);
        }
        
        if (self.capturedCameraFrame != nil)
        {
            // If an image was captured as well, save the image.
            self.capturedContext.uiImage = self.capturedCameraFrame;
        }
        
        if(didRecordMemo)
        {
            self.capturedContext.hasMemo = TRUE;
            if (![[NSFileManager defaultManager] moveItemAtPath:temporaryMemoFilePath toPath:self.capturedContext.memoFilePath error:&error])
            {
                NSLog(@"Error moving file from %@ to %@: %@", temporaryMemoFilePath, self.capturedContext.memoFilePath, [error localizedDescription]);
            }
        }
        // Add the current CapturedContext to the CapturedContextManager's list,
        // and save to disk.
        [[CapturedContextManager sharedManager].capturedContexts addObject:self.capturedContext];
        [[CapturedContextManager sharedManager] saveCapturedContextList];
    }
    else
    {
        NSLog(@"ContextCaptureViewController Error: attempt to save nil CapturedContext");
    }
}

- (void)justSaveCapturedContextToAlbum
{
    [self saveCapturedContext];
    
    NSString *message = @"Saved to album";
    NSLog(@"%@", message);
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, message);
    
    [self restartCapture];
}

- (void)saveCapturedContextAndTagToBeSent
{
    self.capturedContext.taggedForSending = YES;
    
    [self saveCapturedContext];
    
    NSString *message = @"Saved and tagged to be sent later";
    NSLog(@"%@", message);
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, message);
    
    [self restartCapture];
}

- (void)saveCapturedContextAndSendToGroup:(NSString *)group
{
    [self saveCapturedContext];
    
    // FIX: hardcoded message. 
    if (self.capturedContext != nil && self.capturedContext.uiImage != nil)
    {
        [[WebRequestManager sharedManager] uploadImage:self.capturedContext.uiImage forUser:[UserManager sharedManager].currentUser toGroup:group withMessage:@"What is this?"];
        NSString *message = [NSString stringWithFormat:@"Sent captured photo to group %@", group];
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, message);
    }
}

- (void)exitCapture
{
    // Stop recording
    [self stopAudioCapture];
    [self stopCameraFrameCapture];
    
    NSString *message = @"Exiting camera mode";
    NSLog(@"%@", message);
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, message);
    
    [self.delegate contextCaptureViewControllerFinished:self];
}

#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder
{
    NSLog(@"audioRecorderBeginInterruption called");
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSLog(@"audioRecorderDidFinishRecording called: flag=%d at %@", flag, recorder.url);
    if (flag == YES)
    {
        if (!didRecordMemo)
        {
            savingAudioFile = NO;
            if (restartAudioRecordingAfterSaveCompletes)
            {
                restartAudioRecordingAfterSaveCompletes = NO;
                [self startAudioCapture];
            }
        }
    }
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog(@"audioRecorderEncodeErrorDidOccur called");
}

- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder
{
    NSLog(@"audioRecorderEndInterruption called");
}

- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withFlags:(NSUInteger)flags
{
    NSLog(@"audioRecorderEndInterruption called");
}

@end
