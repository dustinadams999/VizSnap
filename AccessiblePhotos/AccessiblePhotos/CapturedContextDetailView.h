//
//  CapturedContextDetailView.h
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/08/09.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "CapturedContext.h"

@class CapturedContextDetailView;

@protocol CapturedContextDetailViewDelegate <NSObject>

- (void)capturedContextDetailViewPhotoTapped:(CapturedContextDetailView *)sender;

@end

@interface CapturedContextDetailView : UIView <MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) CapturedContext *capturedContext;
@property (nonatomic, weak) id<CapturedContextDetailViewDelegate> delegate;

- (void)startPlayingAudio;
- (void)stopPlayingAudio;
- (void)hideInformationOverlay;
- (void)showInformationOverlay;


@end