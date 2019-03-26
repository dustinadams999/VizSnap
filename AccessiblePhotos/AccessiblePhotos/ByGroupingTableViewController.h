//
//  ByGroupingTableViewController.h
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/08/02.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TreeNode.h"

@interface ByGroupingTableViewController : UITableViewController

@property (nonatomic, weak) TreeNode *groupingParentNode;

@end
