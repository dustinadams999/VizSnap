//
//  CapturedContextActionHeaderView.h
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/08/01.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CapturedContext.h"

@class CapturedContextActionHeaderView;

@protocol CapturedContextActionHeaderViewDelegate <NSObject>

- (void)capturedContextActionHeaderViewTagToSendLater:(CapturedContextActionHeaderView *)sender;

@end

@interface CapturedContextActionHeaderView : UIView

@property (nonatomic, weak) CapturedContext *capturedContext;
@property (nonatomic, weak) id<CapturedContextActionHeaderViewDelegate> delegate;

- (void)startAudio;
- (void)stopAudio;

@end
