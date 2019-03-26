//
//  ImageCaptureViewController.h
//  NewAppPrototype
//
//  Created by 原田 丞 on 12/07/05.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraFrameCaptureHelper.h"
#import "CapturedContext.h"

@class ContextCaptureViewController;

@protocol ContextCaptureViewControllerDelegate <NSObject>

- (void)contextCaptureViewControllerFinished:(ContextCaptureViewController *)sender;

@end

@interface ContextCaptureViewController : UIViewController

@property (nonatomic, weak) id<ContextCaptureViewControllerDelegate> delegate;

@end
