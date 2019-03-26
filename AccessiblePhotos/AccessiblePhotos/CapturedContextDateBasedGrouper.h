//
//  CapturedContextDateBasedGrouper.h
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/08/02.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CapturedContextGroupingNodeDataBase.h"
#import "CapturedContext.h"
#import "TreeNode.h"

typedef enum
{
    kDateGroupingLevelYear,
    kDateGroupingLevelMonth,
    kDateGroupingLevelDay,
    kDateGroupingLevelAtomic
} DateGroupingLevel;


@interface DateGroupingNodeData : CapturedContextGroupingNodeDataBase

@property (nonatomic, readonly) DateGroupingLevel groupingLevel;
@property (nonatomic, readonly) NSDate *groupingTimestamp;
@property (nonatomic, readonly) NSDateComponents *groupingTimestampDateComponents;

- (id)initWithLevel:(DateGroupingLevel)level timestamp:(NSDate *)timestamp;
- (BOOL)containsTime:(NSDate *)timestamp;
- (NSComparisonResult)compare:(DateGroupingNodeData *)otherObject;

@end

@interface CapturedContextDateBasedGrouper : NSObject

@property (nonatomic, strong, readonly) TreeNode *groupingRootNode;

- (void)reset;
- (void)addCapturedContext:(CapturedContext *)capturedContext;
- (void)removeCapturedContext:(CapturedContext *)capturedContext;

@end
