//
//  CapturedContextGroupingNodeDataBase.h
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/08/09.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TreeNode.h"
#import "CapturedContext.h"

@interface CapturedContextGroupingNodeDataBase : NSObject <ComparableTreeNode>

@property (nonatomic, copy, readonly) NSString *groupingName;
// Only applicable for leaf nodes
@property (nonatomic, weak) CapturedContext *capturedContext;

- (NSComparisonResult)compare:(CapturedContextGroupingNodeDataBase *)otherObject;

@end
