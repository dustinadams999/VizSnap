//
//  ValueSelectionViewController.h
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/07/31.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ValueSelectionViewController;

@protocol ValueSelectionViewControllerDelegate <NSObject>

- (void)valueSelectionViewController:(ValueSelectionViewController *)controller valueSelected:(id)selectedValue atIndex:(int)selectedValueIndex;

@end

@interface ValueSelectionViewController : UITableViewController

@property (nonatomic, weak) id<ValueSelectionViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *values;
@property (nonatomic, strong) id selectedValue;
@property (nonatomic, copy) NSString *valueSuffix;
@property (nonatomic, copy) NSString *message;

@end