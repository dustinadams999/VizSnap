//
//  CapturedContextGroupingNodeDataBase.m
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/08/09.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "CapturedContextGroupingNodeDataBase.h"

@implementation CapturedContextGroupingNodeDataBase

@synthesize groupingName;
@synthesize capturedContext;

#pragma mark - ComparableTreeNode protocol methods

- (NSComparisonResult)compare:(CapturedContextGroupingNodeDataBase *)otherObject
{
    // Default implementation
    return [capturedContext.timestamp compare:otherObject.capturedContext.timestamp];
}

@end
