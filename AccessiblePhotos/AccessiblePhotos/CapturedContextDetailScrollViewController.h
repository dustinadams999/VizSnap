//
//  CapturedContextDetailScrollViewController.h
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/08/09.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TreeNode.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@class CapturedContextDetailScrollViewController;

@protocol CapturedContextDetailScrollViewControllerDelegate <NSObject>

- (void)capturedContextDetailScrollViewController:(CapturedContextDetailScrollViewController *)sender focusedPageIndexChangedTo:(int)pageIndex;

@end

@interface CapturedContextDetailScrollViewController : UIViewController<MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) id<CapturedContextDetailScrollViewControllerDelegate> delegate;

@property (nonatomic, weak) TreeNode *rootNode;
@property (nonatomic, assign) int focusedPageIndex;
@property (nonatomic, copy) NSString *titleText;
@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *facebookButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *emailButton;
@property (strong, nonatomic) SLComposeViewController *mySLComposerSheet;
- (IBAction)facebookSend:(id)sender;
- (IBAction)emailSend:(id)sender;

@end
