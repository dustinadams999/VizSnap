//
//  CaptureGestureHandler.h
//  NewAppPrototype
//
//  Created by 原田 丞 on 12/07/18.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccessibleGestureView.h"

@class CaptureGestureHandler;

@protocol CaptureGestureHandlerDelegate <NSObject>

@optional
- (void)captureGestureHandler:(CaptureGestureHandler *)sender recognizedTapGestureWithNumTaps:(int)numTaps withNumTouches:(int)numTouches;
- (void)captureGestureHandler:(CaptureGestureHandler *)sender recognizedSwipeGestureWithSwipeDirection:(UISwipeGestureRecognizerDirection)direction withNumTouches:(int)numTouches;
- (void)captureGestureHandler:(CaptureGestureHandler *)sender recognizedLongPressGestureStartWithNumTaps:(int)numTaps withNumTouches:(int)numTouches;
- (void)captureGestureHandler:(CaptureGestureHandler *)sender recognizedLongPressGestureEndWithNumTaps:(int)numTaps withNumTouches:(int)numTouches;

@end

@interface CaptureGestureHandler : NSObject

@property (nonatomic, weak) AccessibleGestureView *accessibleGestureView;
@property (nonatomic, weak) id<CaptureGestureHandlerDelegate> delegate;

@end
