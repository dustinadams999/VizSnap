//
//  GestureBasedContextCaptureViewController.m
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/07/24.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "GestureBasedContextCaptureViewController.h"
#import "AccessibleGestureView.h"
#import "CaptureGestureHandler.h"
#import "ContextCaptureViewController_Protected.h"
//#import "UserManager.h"

typedef enum
{
    kGestureBasedContextCaptureStateInitial,
    kGestureBasedContextCaptureStateAwaitingMemo
    
} GestureBasedContextCaptureState;

@interface GestureBasedContextCaptureViewController () <AccessibleGestureViewDelegate,  CaptureGestureHandlerDelegate>

@property (nonatomic, assign) GestureBasedContextCaptureState currentState;

@end

@implementation GestureBasedContextCaptureViewController
{
    UILabel *instructionLabel;
    AccessibleGestureView *accessibleGestureView;
    CaptureGestureHandler *captureGestureHandler;
    NSString *currentStatus;
    UILabel *recordingAudioLabel;
    bool recordingLabelShouldBeShowing;
    bool recordingLabelIsShowing;
}

@synthesize currentState = _currentState;
@synthesize delegate;

- (void)setCurrentState:(GestureBasedContextCaptureState)newState
{
    _currentState = newState;
    
    switch (self.currentState) {
            //removing the Swipe right (1-finger) statement because we're removing that option for right now. June 4, 2015
        case kGestureBasedContextCaptureStateInitial:
            [instructionLabel setFont:[UIFont boldSystemFontOfSize:18]];
            instructionLabel.text = @"(VoiceOver Gestures)\nSingle-tap (1-finger): enable gesture\nSingle-tap (2-finger): toggle help\nSwipe left (1-finger): cancel\nSwipe down (1-finger): save to album\nSwipe up (1-finger): save and\nrecord memo";
            currentStatus = @"Audio is recording.";
            [recordingAudioLabel setHidden:false];
            recordingLabelShouldBeShowing = true;
            
            //Here we can start recording with OpenEars and make a long list of words we actually detect. We shouldn't commit that list to memory (save) until the user has swiped left (meaning they capture a photo).
            break;
            
        case kGestureBasedContextCaptureStateAwaitingMemo:
            [instructionLabel setFont:[UIFont boldSystemFontOfSize:18]];
            instructionLabel.text = @"(VoiceOver Gestures)\nSingle-tap (2-finger): toggle help\nSwipe left (1-finger): cancel\nSwipe up (1-finger): save to album\nTap and hold (1-finger): start\nrecording memo";
//            currentStatus = @"Photo has been captured. Audio is not recording. Tap and hold to begin memo recording, or swipe up to save without memo, or swipe left to cancel and start recording new audio.";
            currentStatus = @"Record memo?";
            [recordingAudioLabel setHidden:true];
            recordingLabelShouldBeShowing = false;
            break;
    }
}

- (void)viewDidLoad
{
    NSLog(@"GestureBasedContextCaptureViewController: viewDidLoad called");
    
    [super viewDidLoad];
    
    //////////////////////////////////////////////
    // Set up the AccessibleGestureView to be able to process
    // various gestures performed over the camera view.
    accessibleGestureView = [[AccessibleGestureView alloc] initWithFrame:self.view.bounds];
    accessibleGestureView.delegate = self;
    // FIX: meaningless? remove?
//    accessibleGestureView.accessibilityLabel = @"Camera view";
//    accessibleGestureView.accessibilityHint = @"First tap once to activate the camera, then swipe down to quick capture, swipe right to capture and preview, swipe up to tag to send later, and swipe left to exit camera mode.";
    accessibleGestureView.accessibilityLabel = @"Tap once to enable gestures and tap once with two fingers to hear available gestures.";
    accessibleGestureView.accessibilityHint = @"";
    [self.view addSubview:accessibleGestureView];
    
    
    //////////////////////////////////////////////
    // Set up the gesture handler for processing gestures performed
    // on the accessibleGestureView.
    captureGestureHandler = [CaptureGestureHandler new];
    captureGestureHandler.delegate = self;
    captureGestureHandler.accessibleGestureView = accessibleGestureView;
    
    
    //////////////////////////////////////////////
    // Set up the instruction label to be overlayed over the
    // camera view for sighted users.
    instructionLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
    instructionLabel.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6];
    instructionLabel.isAccessibilityElement = NO;
    instructionLabel.numberOfLines = 8;
    [self.view addSubview:instructionLabel];

    self.currentState = kGestureBasedContextCaptureStateInitial;
    
    //THIS IS PROBABLY A GOOD PLACE TO TELL OPENEARS TO START LISTENING FOR KEYWORDS FOR THE AMBIENT AUDIO. THE LIST OF WORDS DETECTED WILL BE SAVED ONCE THE PHOTO IS CAPTURED AND NOT CANCELED
    
    //add the Recording Audio label
    recordingAudioLabel = [UILabel new];
    [recordingAudioLabel setText:@"Recording Audio"];
    [recordingAudioLabel setTextColor:[UIColor redColor]];
    [recordingAudioLabel setFont:[UIFont boldSystemFontOfSize:17]];
    //[recordingAudioLabel setFrame:CGRectMake(173, 47, 140, 21)];
    [recordingAudioLabel setFrame:CGRectMake(173, self.view.frame.size.height - 100, 140, 21)];
    [self.view addSubview:recordingAudioLabel];
    [recordingAudioLabel setHidden:false];
    
    recordingLabelIsShowing = true;
    
    recordingLabelShouldBeShowing = true;
    
    //This timer is what makes the recording label blink
    [NSTimer scheduledTimerWithTimeInterval:.5
                                     target:self
                                   selector:@selector(changeLabel)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //    accessibleGestureView.accessibilityLabel = @"Gesture enabled. Tap once to start audio recording.";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    accessibleGestureView.accessibilityLabel = @"Gestures enabled.";

    NSLog(@"######## GestureBasedContextCaptureViewController: didAppear");
//    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Audio is recording. Tap once to enable gesture mode, and you should hear \"gesture enabled.\" To save photo to album, swipe down. To capture photo and record memo, swipe up. To capture photo and preview the recorded audio, swipe right. To cancel swipe left.");
//    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Tap once to enable gesture mode.");
}

- (void)viewDidUnload
{
    NSLog(@"ImageCaptureViewController: viewDidUnload: self.view = %@", self.view);
    
    [super viewDidUnload];
    
    captureGestureHandler.accessibleGestureView = nil;
    captureGestureHandler.delegate = nil;
    captureGestureHandler = nil;
    
    accessibleGestureView.delegate = nil;
    accessibleGestureView = nil;
    instructionLabel = nil;
}

-(void)changeLabel
{
    //only blink the label if it SHOULD be on
    if(recordingLabelShouldBeShowing)
    {
        if (recordingLabelIsShowing)
        {
            //[recordingAudioLabel setText:@""];
            [recordingAudioLabel setHidden:true];
            recordingLabelIsShowing = false;
        }
        else
        {
            //[recordingAudioLabel setText:@"Recording Audio"];
            [recordingAudioLabel setHidden:false];
            recordingLabelIsShowing = true;
        }
    }
}

#pragma mark - Private instance methods

- (void)announceCurrentStatus
{
    if (currentStatus != nil)
    {
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, currentStatus);
    }

}

#pragma mark - AccessibleGestureViewDelegate

- (void)accessibleGestureViewDidBecomeFocused:(AccessibleGestureView *)view
{
    NSLog(@"##################### GestureBasedContextCaptureViewController: accessibleGestureViewDidBecomeFocused");

    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Tap once to enable gestures and tap once with two fingers to hear available gestures.");
}

#pragma mark - CaptureGestureHandlerDelegate

- (void)captureGestureHandler:(CaptureGestureHandler *)sender recognizedLongPressGestureStartWithNumTaps:(int)numTaps withNumTouches:(int)numTouches
{
    //NSLog(@"Handler method called, numTaps: %d, numTouches: %d", numTaps, numTouches);
    //here, tell this handler to start recording the audio until the long press is released
    if (numTouches == 1 && numTaps == 0)
    {
        //here, call the captureVoiceMemo method
        //NSLog(@"Starting long press");
        //also, define what happens in the action sheet
        //[super startVoiceMemoCapture];

        if (self.currentState == kGestureBasedContextCaptureStateAwaitingMemo)
        {
            //HERE WE NEED TO TELL OPENEARS TO START LISTENING AND GATHERING KEYWORDS FOR THE VOICE MEMOS
            
            recordingLabelShouldBeShowing = true;
            
            [recordingAudioLabel setHidden:false];
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"");
            [self startMemoAudioCapture];
            

        }
    }
}

- (void)captureGestureHandler:(CaptureGestureHandler *)sender recognizedLongPressGestureEndWithNumTaps:(int)numTaps withNumTouches:(int)numTouches
{
    //NSLog(@"Handler method called, numTaps: %d, numTouches: %d", numTaps, numTouches);
    //here, tell this handler to start recording the audio until the long press is released
    if (numTouches == 1 && numTaps == 0)
    {
        if (self.currentState == kGestureBasedContextCaptureStateAwaitingMemo)
        {
            //here, we need to stop the audio recording
            //[super stopVoiceMemoCapture];
            
            __weak GestureBasedContextCaptureViewController *weakSelf = self;
            
            [super stopMemoAudioCaptureWithCompletion:^(ContextCaptureHelper *sender, BOOL success) {
                // commit the memo audio into capturedContext
                if ([weakSelf commitCapturesToCapturedContext] == YES)
                {
                    //WE NEED TO SAVE THE KEYWORDS DETECTED BY OPENEARS FOR THE VOICEMEMO IN THIS BLOCK OF CODE HERE
                    
                    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Saved.");
                }
                else
                {
                    NSLog(@"ERROR: GestureBasedContextCaptureViewController: unable to commit captures with memo.");
                    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Failed to save memo with photo and audio.");
                }
                
                weakSelf.currentState = kGestureBasedContextCaptureStateInitial;
                
                // Restart capture
                [super clearCapturedContext];
                [weakSelf startPhodioCapturePlaySound:NO];
            }];
        }
    }
}

- (void)captureGestureHandler:(CaptureGestureHandler *)sender recognizedTapGestureWithNumTaps:(int)numTaps withNumTouches:(int)numTouches
{
    if (numTouches == 1 && numTaps == 1)
    {
        if (self.currentState == kGestureBasedContextCaptureStateAwaitingMemo)
        {
            [self announceCurrentStatus];
        }
        else if (self.currentState == kGestureBasedContextCaptureStateInitial)
        {
            __weak ContextCaptureViewController *weakSelf = self;
            // restart phodio capture
            [super stopPhodioCaptureKeepingFiles:NO playSound:NO withCompletion:^{
                [weakSelf startPhodioCapturePlaySound:YES];
            }];
        }

    }
    else if (numTouches == 1 && numTaps == 2)
    {
        // One-finger double-tap
//        [self announceCurrentStatus];
    }
    else if (numTouches == 2 && numTaps == 1)
    {
        instructionLabel.hidden = !instructionLabel.isHidden;
        //here the accessibility menu needs to be announced via voiceover
        if (instructionLabel.hidden)
        {
            //For right now, we're removing the part that says "Swipe right to save and preview". June 4, 2015
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Single-tap with 1-finger to enable gesture. Single-tap with 2-fingers to toggle help. Swipe left with 1-finger to cancel. Swipe down with 1-finger to save to album. Swipe up with 1-finger to save and record voice memo.");
        }
    }
}

- (void)captureGestureHandler:(CaptureGestureHandler *)sender recognizedSwipeGestureWithSwipeDirection:(UISwipeGestureRecognizerDirection)direction withNumTouches:(int)numTouches
{
    if (self.currentState == kGestureBasedContextCaptureStateInitial)
    {
        if (numTouches == 1)
        {
            switch (direction) {
                case UISwipeGestureRecognizerDirectionLeft:
                    
                    [super exitCapture];
                    break;
                case UISwipeGestureRecognizerDirectionDown:
                    // Just save to album
                    
                    //HERE WE NEED TO SAVE THE LIST OF KEYWORDS THAT OPENEARS DETECTED FROM THE AMBIENT AUDIO - NOT VOICE MEMO. WE NEED TO FIGURE OUT IN WHICH DATASTRUCTURE THE LIST OF KEYWORDS IS GOING TO BE SAVED WITH.
                    
                    [super saveCapturedContextAndResumeCaptureWithCompletion:nil];
                    break;
                case UISwipeGestureRecognizerDirectionUp:
                    // Wait for memo
                    
                    //FIRST WE NEED TO SAVE THE KEYWORDS THAT OPENEARS DETECTED FROM THE AMBIENT AUDIO. UPTOP IN THE TAP-AND-HOLD EVENT HANDLER, THAT'S WHERE WE NEED TO SAVE THE VOICE MEMO KEYWORDS, AS SOON AS THE USER LIFTS THEIR FINGER
                    {
                        __weak GestureBasedContextCaptureViewController *weakSelf = self;
                        
                        
                        
                        // FIX: just capture photo and keep ambient audio recording going?
//                      [super.contextCaptureHelper stopPhotoCapture];
                        [super stopPhodioCaptureKeepingFiles:YES playSound:YES withCompletion:^{
                            weakSelf.currentState = kGestureBasedContextCaptureStateAwaitingMemo;
                            [weakSelf announceCurrentStatus];
                        }];
                    }
                    break;
                case UISwipeGestureRecognizerDirectionRight:
                    // Send to group
                    // the below saveCapturedContextAndPromptWhatToDo line is commented out because we don't necessarily need that preview option. June 4, 2015
                    // [super saveCapturedContextAndPromptWhatToDo];
                    break;
                default:
                    break;
            }
        }
    }
    else if (self.currentState == kGestureBasedContextCaptureStateAwaitingMemo)
    {
        if (numTouches == 1)
        {
            //this is a swipe left (i.e. cancel)
            switch (direction) {
                case UISwipeGestureRecognizerDirectionLeft:
                    {
                        __weak GestureBasedContextCaptureViewController *weakSelf = self;

                        // TODO: discard capture, and resume phodio capture
                        [super discardCapturedContextWithCompletion:^(ContextCaptureViewController *sender) {
                            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Discarded.");
                            
                            weakSelf.currentState = kGestureBasedContextCaptureStateInitial;
                            [super startPhodioCapturePlaySound:NO];
                        }];
                    }
                    
                    break;
                case UISwipeGestureRecognizerDirectionDown:
                    break;
                case UISwipeGestureRecognizerDirectionUp:
                    {
                        if ([super commitCapturesToCapturedContext] == YES)
                        {
                            self.currentState = kGestureBasedContextCaptureStateInitial;
                            
                            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Saved without memo.");
                            
                            //HERE WE NEED TO SAVE THE LIST OF KEYWORDS THAT OPENEARS DETECTED FROM THE AMBIENT AUDIO - NOT VOICE MEMO. WE NEED TO FIGURE OUT IN WHICH DATASTRUCTURE THE LIST OF KEYWORDS IS GOING TO BE SAVED WITH.
                            
                            
                            // Restart capture
                            [super clearCapturedContext];
                            [super startPhodioCapturePlaySound:NO];
                        }
                        else
                        {
                            NSLog(@"ERROR: GestureBasedContextCaptureViewController: unable to commit captures without memo");
                            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Failed to save photo and audio without memo.");
                        }
                    }
                    break;
                case UISwipeGestureRecognizerDirectionRight:
                    break;
                default:
                    break;
            }
        }
    }
}

@end
