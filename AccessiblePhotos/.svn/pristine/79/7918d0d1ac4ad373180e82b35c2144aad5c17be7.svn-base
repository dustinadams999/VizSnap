//
//  AccessibleGestureView.m
//  NewAppPrototype
//
//  Created by 原田 丞 on 12/07/13.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "AccessibleGestureView.h"

@implementation AccessibleGestureView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isAccessibilityElement = YES;
        self.accessibilityTraits |= UIAccessibilityTraitAllowsDirectInteraction;
    }
    return self;
}

#pragma mark - UIAccessibilityFocus informal protocol overrides

- (void)accessibilityElementDidLoseFocus
{
    NSLog(@"AccessibleGestureView: accessibilityElementDidLoseFocus");
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(accessibleGestureViewDidLoseFocus:)]) {
        [self.delegate accessibleGestureViewDidLoseFocus:self];
    }
}

- (void)accessibilityElementDidBecomeFocused
{
    NSLog(@"AccessibleGestureView: accessibilityElementDidBecomeFocused");
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(accessibleGestureViewDidBecomeFocused:)]) {
        [self.delegate accessibleGestureViewDidBecomeFocused:self];
    }
}

#pragma mark - UIResponder overrides

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canResignFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    return YES;
}

- (BOOL)resignFirstResponder
{
    return YES;
}

#pragma mark - UIGestureRecognizer methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(accessibleGestureView:touchesBegan:withEvent:)]) {
        [self.delegate accessibleGestureView:self touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(accessibleGestureView:touchesMoved:withEvent:)]) {
        [self.delegate accessibleGestureView:self touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(accessibleGestureView:touchesEnded:withEvent:)]) {
        [self.delegate accessibleGestureView:self touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(accessibleGestureView:touchesCancelled:withEvent:)]) {
        [self.delegate accessibleGestureView:self touchesCancelled:touches withEvent:event];
    }
}

@end
