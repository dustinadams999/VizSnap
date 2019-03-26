//
//  ContextCaptureViewController_Protected.h
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/07/24.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "ContextCaptureViewController.h"
#import "ContextCaptureHelper.h"

typedef void (^CommitCapturedContextCompletionCallback)(ContextCaptureViewController *sender, CapturedContext *committedCapturedContext);
typedef void (^DiscardCapturedContextCompletionCallback)(ContextCaptureViewController *sender);
typedef void (^ExitCaptureCompletionCallback)(ContextCaptureViewController *sender);

@interface ContextCaptureViewController ()

@property (nonatomic, strong, readonly) ContextCaptureHelper *contextCaptureHelper;
@property (nonatomic, strong, readonly) CapturedContext *capturedContext;

- (void)clearCapturedContext;

- (void)startMemoAudioCapture;
- (void)stopMemoAudioCaptureWithCompletion:(CaptureCompletionCallback)completionCallback;
// Always clears any previous capture before starting
- (BOOL)startPhodioCapturePlaySound:(BOOL)playSound;
// Always "snaps" the phodio
- (void)stopPhodioCaptureKeepingFiles:(BOOL)keepFiles playSound:(BOOL)playSound withCompletion:(void (^)())completionCallback;

- (void)pauseCapture;
- (void)resumeCapture;

- (BOOL)commitCapturesToCapturedContext;

//- (void)capturePhodioAndCommitToCapturedContextWithCompletion:(CommitCapturedContextCompletionCallback)completionCallback;

- (void)discardCapturedContextWithCompletion:(DiscardCapturedContextCompletionCallback)completionCallback;
// stop capture if necessary, then commit captures, then resume?
- (void)saveCapturedContextAndResumeCaptureWithCompletion:(CommitCapturedContextCompletionCallback)completionCallback; // calls commitCapture on helper
- (void)saveCapturedContextAndTagToBeSent; // call commitCapture and then tag 
- (void)saveCapturedContextAndPromptWhatToDo;

- (void)exitCapture;

@end
