//
//  CapturedContextActionViewController.h
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/08/01.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CapturedContext.h"

@class CapturedContextActionViewController;

@protocol CapturedContextActionViewControllerDelegate <NSObject>

- (void)capturedContextActionViewControllerDiscard:(CapturedContextActionViewController *)sender;
- (void)capturedContextActionViewControllerFinished:(CapturedContextActionViewController *)sender;
- (void)capturedContextActionViewControllerTagToSendLater:(CapturedContextActionViewController *)sender;
- (void)capturedContextActionViewController:(CapturedContextActionViewController *)sender sendToGroup:(NSString *)groupName atIndex:(int)groupIndex;

@end

@interface CapturedContextActionViewController : UITableViewController

@property (nonatomic, weak) CapturedContext *capturedContext;
@property (nonatomic, copy) NSArray *groupsToSendTo;

@property (nonatomic, weak) id<CapturedContextActionViewControllerDelegate> delegate;

@end
