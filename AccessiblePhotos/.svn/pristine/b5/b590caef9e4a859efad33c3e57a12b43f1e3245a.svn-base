//
//  CaptureGestureHandler.m
//  NewAppPrototype
//
//  Created by 原田 丞 on 12/07/18.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "CaptureGestureHandler.h"

@interface CaptureGestureHandler ()

@end

@implementation CaptureGestureHandler
{
    NSMutableArray *gestureRecognizers;
}

@synthesize accessibleGestureView;
@synthesize delegate;

- (id)init
{
    if (self = [super init])
    {
        gestureRecognizers = [NSMutableArray new];
    }
    return self;
}

- (void)setAccessibleGestureView:(AccessibleGestureView *)view
{
    if (accessibleGestureView != view)
    {
        [self unregisterGestureRecognizersForAccessibleGestureView:accessibleGestureView];
        accessibleGestureView = view;
        [self registerGestureRecognizersForAccessibleGestureView:accessibleGestureView];
    }
}

#pragma mark - Private instance methods

- (void)registerGestureRecognizersForAccessibleGestureView:(AccessibleGestureView *)view
{
    if (view != nil)
    {
        UISwipeGestureRecognizer *oneFingerSwipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
        oneFingerSwipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        oneFingerSwipeRightGestureRecognizer.numberOfTouchesRequired = 1;
        [view addGestureRecognizer:oneFingerSwipeRightGestureRecognizer];
        [gestureRecognizers addObject:oneFingerSwipeRightGestureRecognizer];
        
        UISwipeGestureRecognizer *oneFingerSwipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
        oneFingerSwipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        oneFingerSwipeLeftGestureRecognizer.numberOfTouchesRequired = 1;
        [view addGestureRecognizer:oneFingerSwipeLeftGestureRecognizer];
        [gestureRecognizers addObject:oneFingerSwipeLeftGestureRecognizer];
        
        UISwipeGestureRecognizer *oneFingerSwipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
        oneFingerSwipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
        oneFingerSwipeUpGestureRecognizer.numberOfTouchesRequired = 1;
        [view addGestureRecognizer:oneFingerSwipeUpGestureRecognizer];
        [gestureRecognizers addObject:oneFingerSwipeUpGestureRecognizer];

        UISwipeGestureRecognizer *oneFingerSwipeDownGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
        oneFingerSwipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
        oneFingerSwipeDownGestureRecognizer.numberOfTouchesRequired = 1;
        [view addGestureRecognizer:oneFingerSwipeDownGestureRecognizer];
        [gestureRecognizers addObject:oneFingerSwipeDownGestureRecognizer];

        UITapGestureRecognizer *oneFingerDoubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        oneFingerDoubleTapRecognizer.numberOfTouchesRequired = 1;
        oneFingerDoubleTapRecognizer.numberOfTapsRequired = 2;
        [view addGestureRecognizer:oneFingerDoubleTapRecognizer];
        [gestureRecognizers addObject:oneFingerDoubleTapRecognizer];
        
        UITapGestureRecognizer *oneFingerSingleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        oneFingerSingleTapRecognizer.numberOfTouchesRequired = 1;
        oneFingerSingleTapRecognizer.numberOfTapsRequired = 1;
        [oneFingerSingleTapRecognizer requireGestureRecognizerToFail:oneFingerDoubleTapRecognizer];
        [view addGestureRecognizer:oneFingerSingleTapRecognizer];
        [gestureRecognizers addObject:oneFingerSingleTapRecognizer];
        
        UITapGestureRecognizer *twoFingerSingleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        twoFingerSingleTapRecognizer.numberOfTouchesRequired = 2;
        twoFingerSingleTapRecognizer.numberOfTapsRequired = 1;
        [view addGestureRecognizer:twoFingerSingleTapRecognizer];
        [gestureRecognizers addObject:twoFingerSingleTapRecognizer];
        
        UILongPressGestureRecognizer *singleFingerLongPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        singleFingerLongPressRecognizer.numberOfTouchesRequired = 1;
        singleFingerLongPressRecognizer.numberOfTapsRequired = 0;
        [view addGestureRecognizer:singleFingerLongPressRecognizer];
        [gestureRecognizers addObject:singleFingerLongPressRecognizer];
    }
}

- (void)unregisterGestureRecognizersForAccessibleGestureView:(AccessibleGestureView *)view
{
    if (view != nil)
    {
        for (UIGestureRecognizer *gestureRecognizer in gestureRecognizers)
        {
            [view removeGestureRecognizer:gestureRecognizer];
        }
    }
}

#pragma mark - Responding to gestures

- (void)handleSwipeGesture:(UIGestureRecognizer *)gestureRecognizer
{
    UISwipeGestureRecognizer *swipeGestureRecognizer = (UISwipeGestureRecognizer *)gestureRecognizer;
    int numTouches = swipeGestureRecognizer.numberOfTouchesRequired;
    UISwipeGestureRecognizerDirection direction = swipeGestureRecognizer.direction;
    
    if ([self.delegate respondsToSelector:@selector(captureGestureHandler:recognizedSwipeGestureWithSwipeDirection:withNumTouches:)])
    {
        [self.delegate captureGestureHandler:self recognizedSwipeGestureWithSwipeDirection:direction withNumTouches:numTouches];
    }
}

- (void)handleTapGesture:(UIGestureRecognizer *)gestureRecognizer
{
    UITapGestureRecognizer *tapGestureRecognizer = (UITapGestureRecognizer *)gestureRecognizer;
    int numTouches = tapGestureRecognizer.numberOfTouchesRequired;
    int numTaps = tapGestureRecognizer.numberOfTapsRequired;
    
    if ([self.delegate respondsToSelector:@selector(captureGestureHandler:recognizedTapGestureWithNumTaps:withNumTouches:)])
    {
        [self.delegate captureGestureHandler:self recognizedTapGestureWithNumTaps:numTaps withNumTouches:numTouches];
    }
}

- (void)handleLongPressGesture:(UIGestureRecognizer *)gestureRecognizer
{
    UILongPressGestureRecognizer *longPressGestureRecognizer = (UILongPressGestureRecognizer *)gestureRecognizer;
    int numTouches = longPressGestureRecognizer.numberOfTouchesRequired;
    int numTaps = longPressGestureRecognizer.numberOfTapsRequired;
    
    if (longPressGestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        if ([self.delegate respondsToSelector:@selector(captureGestureHandler:recognizedLongPressGestureStartWithNumTaps:withNumTouches:)])
        {
            [self.delegate captureGestureHandler:self recognizedLongPressGestureStartWithNumTaps:numTaps withNumTouches:numTouches];
        }
    }
    else if (longPressGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        if ([self.delegate respondsToSelector:@selector(captureGestureHandler:recognizedLongPressGestureEndWithNumTaps:withNumTouches:)])
        {
            [self.delegate captureGestureHandler:self recognizedLongPressGestureEndWithNumTaps:numTaps withNumTouches:numTouches];
        }
    }
}

@end
