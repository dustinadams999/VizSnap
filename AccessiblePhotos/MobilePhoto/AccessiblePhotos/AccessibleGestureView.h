//
//  AccessibleGestureView.h
//  NewAppPrototype
//
//  Created by 原田 丞 on 12/07/13.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AccessibleGestureView;

@protocol AccessibleGestureViewDelegate <NSObject>

@optional
- (void)accessibleGestureView:(AccessibleGestureView *)view touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)accessibleGestureView:(AccessibleGestureView *)view touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)accessibleGestureView:(AccessibleGestureView *)view touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)accessibleGestureView:(AccessibleGestureView *)view touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)accessibleGestureViewDidLoseFocus:(AccessibleGestureView *)view;
- (void)accessibleGestureViewDidBecomeFocused:(AccessibleGestureView *)view;

@end


@interface AccessibleGestureView : UIView

@property (nonatomic, weak) id<AccessibleGestureViewDelegate> delegate;

@end
