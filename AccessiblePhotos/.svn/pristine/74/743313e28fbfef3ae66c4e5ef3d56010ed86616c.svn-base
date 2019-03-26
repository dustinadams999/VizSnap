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
#import "LocationManager.h"
#import "Settings.h"
#import "FileUtils.h"
#import "AudioRecorder.h"
#import "CapturedContextActionViewController.h"
#import "VolumeButtonListener.h"

#import "AudioSessionManager.h"

@interface ContextCaptureViewController() <CapturedContextActionViewControllerDelegate, VolumeButtonListenerDelegate, AVAudioPlayerDelegate>

@property (nonatomic, weak) IBOutlet UILabel *numFacesLabel;

@end

@implementation ContextCaptureViewController
{
    AVAudioPlayer *cameraShutterPlayer;
    AVAudioPlayer *memoAudioRecordingStartedSoundPlayer;
    AVAudioPlayer *memoAudioRecordingStoppedSoundPlayer;

    AVAudioPlayer *ambientAudioRecordingStartedSoundPlayer;
    AVAudioPlayer *ambientAudioRecordingStoppedSoundPlayer;

//    VolumeButtonListener *volumeButtonListener;
    
    id applicationWillResignActiveObserver;
    id applicationDidEnterBackgroundObserver;
    id applicationWillEnterForegroundObserver;
    id applicationDidBecomeActiveObserver;
    
    BOOL isUsingFrontCamera;
}

@synthesize capturedContext = _capturedContext;
@synthesize contextCaptureHelper;
@synthesize numFacesLabel;
@synthesize delegate;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
//    volumeButtonListener = [VolumeButtonListener new];
//    volumeButtonListener.delegate = self;

    //////////////////////////////////////////////
    // Set up the ContextCaptureHelper.
    contextCaptureHelper = [ContextCaptureHelper new];
    
    
    //////////////////////////////////////////////
    // Set up the audio player for playing the camera shutter sound.
    NSURL *url = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"72714__horsthorstensen__shutter-photo" ofType:@"caf"]];
    NSError *error = nil;
    cameraShutterPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (cameraShutterPlayer == nil)
    {
        NSLog(@"ERROR: ContextCaptureViewController: couldn't initialize cameraShutterPlayer: %@", error.localizedDescription);
    }
    else
    {
        [cameraShutterPlayer prepareToPlay];
    }
    
    
    //////////////////////////////////////////////
    // Set up the audio player for playing the memo recording started sound.
    url = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"23338__altemark__pong" ofType:@"caf"]];
    error = nil;
    memoAudioRecordingStartedSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    memoAudioRecordingStartedSoundPlayer.delegate = self;
    if (memoAudioRecordingStartedSoundPlayer == nil)
    {
        NSLog(@"ERROR: ContextCaptureViewController: couldn't initialize memoAudioRecordingStartedSoundPlayer: %@", error.localizedDescription);
    }
    else
    {
        [memoAudioRecordingStartedSoundPlayer prepareToPlay];
    }
    
    
    //////////////////////////////////////////////
    // Set up the audio player for playing the memo recording stopped sound.
    url = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"23338__altemark__pong_2" ofType:@"caf"]];
    error = nil;
    memoAudioRecordingStoppedSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (memoAudioRecordingStoppedSoundPlayer == nil)
    {
        NSLog(@"ERROR: ContextCaptureViewController: couldn't initialize memoAudioRecordingStoppedSoundPlayer: %@", error.localizedDescription);
    }
    else
    {
        memoAudioRecordingStoppedSoundPlayer.volume = 0.5;
        [memoAudioRecordingStoppedSoundPlayer prepareToPlay];
    }
    
    
    //////////////////////////////////////////////
    // Set up the audio player for playing the ambient audio recording started sound.
    url = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"rising" ofType:@"caf"]];
    error = nil;
    ambientAudioRecordingStartedSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (ambientAudioRecordingStartedSoundPlayer == nil)
    {
        NSLog(@"ERROR: ContextCaptureViewController: couldn't initialize ambientAudioRecordingStartedSoundPlayer: %@", error.localizedDescription);
    }
    else
    {
        [ambientAudioRecordingStartedSoundPlayer prepareToPlay];
    }
    
    
    //////////////////////////////////////////////
    // Set up the audio player for playing the ambient audio recording stopped sound.
    url = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"falling" ofType:@"caf"]];
    error = nil;
    ambientAudioRecordingStoppedSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (ambientAudioRecordingStoppedSoundPlayer == nil)
    {
        NSLog(@"ERROR: ContextCaptureViewController: couldn't initialize ambientAudioRecordingStoppedSoundPlayer: %@", error.localizedDescription);
    }
    else
    {
        [ambientAudioRecordingStoppedSoundPlayer prepareToPlay];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set up the view layer to show the live video stream from the camera.    
    [contextCaptureHelper.cameraFrameCaptureHelper embedPreviewInView:self.view];
    
    self.title = @"Camera view";
    self.navigationItem.title = @"Camera";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [AudioSessionManager sharedManager].currentMode = kAudioSessionModeRecording;
    
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
    applicationWillEnterForegroundObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"com.ibm.research.tokyo.AccessiblePhotos.ApplicationWillEnterForeground" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note)
    {
        [self handleApplicationWillEnterForeground];
    }];
    applicationDidBecomeActiveObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"com.ibm.research.tokyo.AccessiblePhotos.ApplicationDidBecomeActive" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note)
    {
        [self handleApplicationDidBecomeActive];
    }];
    
    //////////////////////////////////////////////
    // disable or enable face detection
    contextCaptureHelper.cameraFrameCaptureHelper.detectFaces = [Settings sharedInstance].faceDetectionEnabled;
    // subscribe to be notified of changes in number of faces detected
    [contextCaptureHelper.cameraFrameCaptureHelper addObserver:self forKeyPath:@"currentNumFacesDetected" options:kNilOptions context:nil];
    if ([Settings sharedInstance].faceDetectionEnabled == NO)
    {
        self.numFacesLabel.hidden = YES;
    }
    else
    {
        self.numFacesLabel.text = @"No faces";
    }
    
    // Start the location manager
    [[LocationManager sharedManager] startUpdatingLocation:[Settings sharedInstance].saveLocationInfo heading:[Settings sharedInstance].saveCompassInfo];


    // If the view controller is just about to be presented,
    // (and not simply appearing after being hidden by a modal dialog)
    // start the phodio capture.
    if (self.isBeingPresented)
    {
        [UIApplication sharedApplication].statusBarHidden = YES;

        [self startPhodioCapturePlaySound:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    // unsubscribe from face detection notification
    [contextCaptureHelper.cameraFrameCaptureHelper removeObserver:self forKeyPath:@"currentNumFacesDetected"];
    
    // Stop the location manager
    [[LocationManager sharedManager] stop];

    // Stop the capture completely.
    if (self.isBeingDismissed)
    {
        [UIApplication sharedApplication].statusBarHidden = NO;
    }
    
    [AudioSessionManager sharedManager].currentMode = kAudioSessionModePlayback;
    
    [[NSNotificationCenter defaultCenter] removeObserver:applicationWillResignActiveObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:applicationDidEnterBackgroundObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:applicationWillEnterForegroundObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:applicationDidBecomeActiveObserver];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    [[contextCaptureHelper.cameraFrameCaptureHelper previewInView:self.view] removeFromSuperlayer];

    [self stopPhodioCaptureKeepingFiles:NO playSound:YES withCompletion:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// FIX: not working, the layer size doesn't seem to be updated to fit
//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    [contextCaptureHelper.cameraFrameCaptureHelper layoutPreviewInView:self.view];
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([@"showCapturedContextActionSegue" isEqualToString:segue.identifier])
    {
        UINavigationController *navController = segue.destinationViewController;
        CapturedContextActionViewController *actionViewController = (CapturedContextActionViewController *)navController.topViewController;
        actionViewController.capturedContext = self.capturedContext;
        actionViewController.delegate = self;
        
        if ([Settings sharedInstance].requestSendingEnabled &&
            [UserManager sharedManager].currentUser != nil &&
            [UserManager sharedManager].currentUser.supporterGroups.count > 0)
        {
            actionViewController.groupsToSendTo = [UserManager sharedManager].currentUser.supporterGroups;
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentNumFacesDetected"])
    {
        int numFaces = contextCaptureHelper.cameraFrameCaptureHelper.currentNumFacesDetected;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (numFaces == 0)
            {
                self.numFacesLabel.text = @"no faces";
            }
            else if (numFaces == 1)
            {
                self.numFacesLabel.text = [NSString stringWithFormat:@"%d face", numFaces];
            }
            else
            {
                self.numFacesLabel.text = [NSString stringWithFormat:@"%d faces", numFaces];
            }
        }];
        
        if (numFaces == 0)
        {
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"no faces");
        }
        else if (numFaces == 1)
        {
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [NSString stringWithFormat:@"%d face", numFaces]);
        }
        else
        {
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [NSString stringWithFormat:@"%d faces", numFaces]);
        }
    }
}

#pragma mark - Protected instance methods

- (void)clearCapturedContext
{
    _capturedContext = nil;
    [contextCaptureHelper discardTemporaryCaptures];
}

- (void)startMemoAudioCapture
{
    // Play sound
    [memoAudioRecordingStartedSoundPlayer play];

    // FIX: hacky: calling inside audioPlayerDidFinishPlaying
    // so that we can ensure the memo start sound doesn't get
    // picked up in the memo recording...
//    [contextCaptureHelper startMemoAudioCapture];
}

- (void)stopMemoAudioCaptureWithCompletion:(CaptureCompletionCallback)completionCallback
{
    CaptureCompletionCallback completionCallbackCopy = [completionCallback copy];
    
    [contextCaptureHelper stopMemoAudioCaptureWithCompletion:^(ContextCaptureHelper *sender, BOOL success) {

        [memoAudioRecordingStoppedSoundPlayer play];

        // TODO: Should we be using different callback?
        if (completionCallbackCopy != nil)
        {
            completionCallbackCopy(sender, success);
        }
    }];
}

- (BOOL)startPhodioCapturePlaySound:(BOOL)playSound
{
    BOOL success = NO;
    
    if (contextCaptureHelper.isCapturingPhodio == NO)
    {
        if (playSound)
        {
            [ambientAudioRecordingStartedSoundPlayer play];
        }
    
        if ([contextCaptureHelper startPhodioCapture] == YES)
        {
            success = YES;
//            [volumeButtonListener start];
        }
        else if (playSound)
        {
            [ambientAudioRecordingStoppedSoundPlayer play];
        }
    }
    return success;
}

- (void)stopPhodioCaptureKeepingFiles:(BOOL)keepFiles playSound:(BOOL)playSound withCompletion:(void (^)())completionCallback
{
    if (keepFiles)
    {
        [cameraShutterPlayer play];
    }

//    [volumeButtonListener stop];
    
    void (^completionCallbackCopy)() = [completionCallback copy];
    
    [contextCaptureHelper stopPhodioCaptureWithCompletion:^(ContextCaptureHelper *sender, BOOL success) {
        if (playSound)
        {
            // FIX: don't play sound stopped sound when shutter already plays?
//            [ambientAudioRecordingStoppedSoundPlayer play];
        }

        if (keepFiles == NO)
        {
            [contextCaptureHelper discardTemporaryPhodioCapture];
        }
        
        if (completionCallbackCopy != nil)
        {
            completionCallbackCopy();
        }
    }];
}

- (void)pauseCapture
{
//    [volumeButtonListener stop];
    [contextCaptureHelper pauseCapture];
}

- (void)resumeCapture
{
    [contextCaptureHelper resumeCapture];
//    [volumeButtonListener start];
}

- (BOOL)commitCapturesToCapturedContext
{
    // Commit whatever has been captured so far into the CapturedContext
    if (_capturedContext == nil)
    {
        _capturedContext = [CapturedContext new];
        [[CapturedContextManager sharedManager] addCapturedContext:_capturedContext];
    }
    
    BOOL success = [contextCaptureHelper commitCapturesToCapturedContext:_capturedContext];
    if (success == YES)
    {
        // FIX: saving here may be causing things to slow down, eventually switch to using CoreData
        [[CapturedContextManager sharedManager] saveCapturedContextList];
    }
    
    return success;
}

- (void)discardCapturedContextWithCompletion:(DiscardCapturedContextCompletionCallback)completionCallback
{
    if (contextCaptureHelper.isCapturingPhodio)
    {
        __weak ContextCaptureViewController *weakSelf = self;
        
        DiscardCapturedContextCompletionCallback completionCallbackCopy = [completionCallback copy];
        
        [contextCaptureHelper stopPhodioCaptureWithCompletion:^(ContextCaptureHelper *sender, BOOL success) {
            [weakSelf discardCapturedContextWithCompletion:completionCallbackCopy];
        }];
    }
    else
    {
        // Discard any temporary captures.
        NSLog(@"######## About to call discardTemporaryCaptures");
        [contextCaptureHelper discardTemporaryCaptures];
        
        // Discard any captured context that was committed but still lying around
        if (self.capturedContext != nil)
        {
            [[CapturedContextManager sharedManager] permanentlyDeleteCapturedContext:self.capturedContext];
            _capturedContext = nil;
        }
        
        if (completionCallback != nil)
        {
            completionCallback(self);
        }
    }
}

- (void)saveCapturedContextAndResumeCaptureWithCompletion:(CommitCapturedContextCompletionCallback)completionCallback
{
    __weak ContextCaptureViewController *weakSelf = self;
    CommitCapturedContextCompletionCallback completionCallbackCopy = [completionCallback copy];
    
    // Stop phodio and memo capture as needed
    if (contextCaptureHelper.isCapturingPhodio)
    {
        [self stopPhodioCaptureKeepingFiles:YES playSound:YES withCompletion:^{
            [weakSelf saveCapturedContextAndResumeCaptureWithCompletion:completionCallbackCopy];
        }];
        return;
    }
    if (contextCaptureHelper.isCapturingMemoAudio)
    {
        [self stopMemoAudioCaptureWithCompletion:^(ContextCaptureHelper *sender, BOOL success) {
            [weakSelf saveCapturedContextAndResumeCaptureWithCompletion:completionCallbackCopy];
        }];
        return;
    }

    if ([self commitCapturesToCapturedContext] == YES)
    {
        NSLog(@"ContextCaptureViewController: Saved captured context to file.");
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Saved");
        
        [self clearCapturedContext];
        
        if (completionCallback != nil)
        {
            completionCallback(self, _capturedContext);
        }

        [self startPhodioCapturePlaySound:NO];
    }
    else
    {
        NSLog(@"ERROR: ContextCaptureViewController: unable to commit captures to CapturedContext.");
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Unable to save.");
    }
}

- (void)saveCapturedContextAndTagToBeSent
{
    __weak ContextCaptureViewController *weakSelf = self;
    
    // Stop phodio and memo capture as needed
    if (contextCaptureHelper.isCapturingPhodio)
    {
        [self stopPhodioCaptureKeepingFiles:YES playSound:YES withCompletion:^{
            [weakSelf saveCapturedContextAndTagToBeSent];
        }];
        return;
    }
    if (contextCaptureHelper.isCapturingMemoAudio)
    {
        [self stopMemoAudioCaptureWithCompletion:^(ContextCaptureHelper *sender, BOOL success) {
            [weakSelf saveCapturedContextAndTagToBeSent];
        }];
        return;
    }

    if ([self commitCapturesToCapturedContext] == YES)
    {
        NSLog(@"ContextCaptureViewController: Saved captured context and tagged to be sent later.");
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Saved and tagged to be sent later");

        _capturedContext.taggedForSending = YES;
        // FIX: this is inefficient, since the CapturedContext has already been committed before this block
        // was called
        [[CapturedContextManager sharedManager] saveCapturedContextList];
        
        [self clearCapturedContext];
        [self startPhodioCapturePlaySound:NO];
    }
    else
    {
        NSLog(@"ERROR: ContextCaptureViewController: unable to commit captures to CapturedContext.");
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Unable to save.");
    }
}

- (void)saveCapturedContextAndPromptWhatToDo
{
    __weak ContextCaptureViewController *weakSelf = self;
    
    // Stop phodio and memo capture as needed
    if (contextCaptureHelper.isCapturingPhodio)
    {
        [self stopPhodioCaptureKeepingFiles:YES playSound:YES withCompletion:^{
            [weakSelf saveCapturedContextAndPromptWhatToDo];
        }];
        return;
    }
    if (contextCaptureHelper.isCapturingMemoAudio)
    {
        [self stopMemoAudioCaptureWithCompletion:^(ContextCaptureHelper *sender, BOOL success) {
            [weakSelf saveCapturedContextAndPromptWhatToDo];
        }];
        return;
    }
  
    // FIX: is this the culprit of the phodio not restarting due to
    // ambient audio recording failing to start after dismissing the dialog?
    if ([self commitCapturesToCapturedContext] == YES)
    {
        NSLog(@"ContextCaptureViewController: Saved captured context and prompting what to do.");
        
        [self performSegueWithIdentifier:@"showCapturedContextActionSegue" sender:self];
    }
    else
    {
        NSLog(@"ERROR: ContextCaptureViewController: unable to commit captures to CapturedContext.");
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Unable to save.");
    }
}

- (void)exitCapture
{
    __weak ContextCaptureViewController *weakSelf = self;
    
    [contextCaptureHelper stopPhodioCaptureWithCompletion:^(ContextCaptureHelper *sender, BOOL success) {
        [sender discardTemporaryCaptures];

        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Exiting camera mode");
        
//        if (success)
//        {
//            [weakSelf->ambientAudioRecordingStoppedSoundPlayer play];
//        }
        [weakSelf.delegate contextCaptureViewControllerFinished:self];
    }];
}

#pragma mark - Private instance methods

- (void)handleApplicationWillResignActive
{
    NSLog(@"ContextCaptureViewController: app willResignActive: pausing capture");
    [self pauseCapture];
}

- (void)handleApplicationDidEnterBackground
{
    NSLog(@"ContextCaptureViewController: app didEnterBackground: stopping phodio capture");
    [self stopPhodioCaptureKeepingFiles:NO playSound:YES withCompletion:nil];
}

- (void)handleApplicationWillEnterForeground
{
    NSLog(@"ContextCaptureViewController: app willEnterForegroundObserver: starting phodio capture");
    [self startPhodioCapturePlaySound:NO];
}

- (void)handleApplicationDidBecomeActive
{
    NSLog(@"ContextCaptureViewController: app didBecomeActive: resuming capture");
    [self resumeCapture];
}

#pragma mark - CapturedContextActionViewControllerDelegate

- (void)capturedContextActionViewControllerDiscard:(CapturedContextActionViewController *)sender
{
    // Discard capture and delete the CapturedContext.
    [self discardCapturedContextWithCompletion:^(ContextCaptureViewController *sender) {
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Discarded.");
        [sender dismissViewControllerAnimated:YES completion:nil];
        [sender startPhodioCapturePlaySound:NO];
    }];
}

- (void)capturedContextActionViewControllerFinished:(CapturedContextActionViewController *)sender
{
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Saved.");
    [self clearCapturedContext];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self startPhodioCapturePlaySound:NO];
}

- (void)capturedContextActionViewControllerTagToSendLater:(CapturedContextActionViewController *)sender
{
    if (self.capturedContext != nil)
    {
        self.capturedContext.taggedForSending = YES;
        [[CapturedContextManager sharedManager] saveCapturedContextList];
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Tagged to send later.");
    }
    [self clearCapturedContext];
    // Dismiss the modal view first so that the audio session gets set to be able to record.
    // FIX:.... do it better..s
    [self dismissViewControllerAnimated:YES completion:nil];
    [self startPhodioCapturePlaySound:NO];
}

- (void)capturedContextActionViewController:(CapturedContextActionViewController *)sender sendToGroup:(NSString *)groupName atIndex:(int)groupIndex
{
    // FIX: hardcoded message. 
    if (self.capturedContext != nil && self.capturedContext.uiImage != nil)
    {
        [[WebRequestManager sharedManager] uploadImage:self.capturedContext.uiImage forUser:[UserManager sharedManager].currentUser toGroup:groupName withMessage:@"What is this?"];
        NSString *message = [NSString stringWithFormat:@"Sent captured photo to group %@", groupName];
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, message);
     
        [self clearCapturedContext];
        [self dismissViewControllerAnimated:YES completion:nil];
        [self startPhodioCapturePlaySound:NO];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - VolumeButtonListenerDelegate

- (void)volumeButtonListenerVolumeUpPressed:(VolumeButtonListener *)listener
{
    [self saveCapturedContextAndResumeCaptureWithCompletion:nil];
}

- (void)volumeButtonListenerVolumeDownPressed:(VolumeButtonListener *)listener
{
    [self saveCapturedContextAndPromptWhatToDo];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (player == memoAudioRecordingStartedSoundPlayer)
    {
        // FIX: hacky: calling inside audioPlayerDidFinishPlaying
        // so that we can ensure the memo start sound doesn't get
        // picked up in the memo recording...
        [contextCaptureHelper startMemoAudioCapture];
    }
}

@end
