//
//  CapturedContextDateBasedGrouper.m
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/08/02.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "CapturedContextDateBasedGrouper.h"

@implementation DateGroupingNodeData

@synthesize groupingLevel;
@synthesize groupingName;
@synthesize groupingTimestamp;
@synthesize groupingTimestampDateComponents;

- (id)initWithLevel:(DateGroupingLevel)level timestamp:(NSDate *)timestamp
{
    return [self initWithLevel:level timestamp:timestamp capturedContext:nil];
}

- (id)initWithLevel:(DateGroupingLevel)level timestamp:(NSDate *)timestamp capturedContext:(CapturedContext *)aCapturedContext
{
    self = [super init];
    if (self)
    {
        self->groupingLevel = level;
        self.capturedContext = aCapturedContext;
        groupingTimestamp = timestamp;
        groupingTimestampDateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:timestamp];
        if (level != kDateGroupingLevelAtomic)
        {
            groupingTimestampDateComponents.second = 0;
            groupingTimestampDateComponents.minute = 0;
            groupingTimestampDateComponents.hour = 0;
        }
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        
        switch (level)
        {
            case kDateGroupingLevelYear:
                groupingTimestampDateComponents.day = 1;
                groupingTimestampDateComponents.month = 1;
                timestamp = [[NSCalendar currentCalendar] dateFromComponents:groupingTimestampDateComponents];
                [dateFormatter setDateFormat:@"yyyy"];
                self->groupingName = [dateFormatter stringFromDate:timestamp];
                break;
            case kDateGroupingLevelMonth:
                groupingTimestampDateComponents.day = 1;
                timestamp = [[NSCalendar currentCalendar] dateFromComponents:groupingTimestampDateComponents];
                // FIX: this formatting is specific to English locale!
                [dateFormatter setDateFormat:@"MMMM yyyy"];
                self->groupingName = [dateFormatter stringFromDate:timestamp];
                break;
            case kDateGroupingLevelDay:
                timestamp = [[NSCalendar currentCalendar] dateFromComponents:groupingTimestampDateComponents];
                [dateFormatter setDateFormat:@"MMMM d"];
                self->groupingName = [dateFormatter stringFromDate:timestamp];
                break;
            case kDateGroupingLevelAtomic:
                self->groupingName = [NSDateFormatter localizedStringFromDate:timestamp dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterLongStyle];
                break;
        }
    }
    return self;
}

- (BOOL)containsTime:(NSDate *)timestamp
{
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:timestamp];

    switch (self.groupingLevel)
    {
        case kDateGroupingLevelYear:
            return (dateComponents.year == groupingTimestampDateComponents.year);
        case kDateGroupingLevelMonth:
            return (dateComponents.month == groupingTimestampDateComponents.month);
        case kDateGroupingLevelDay:
            return (dateComponents.day == groupingTimestampDateComponents.day);
        case kDateGroupingLevelAtomic:
            return (dateComponents.year == groupingTimestampDateComponents.year &&
                    dateComponents.month == groupingTimestampDateComponents.month &&
                    dateComponents.day == groupingTimestampDateComponents.day &&
                    dateComponents.hour == groupingTimestampDateComponents.hour &&
                    dateComponents.minute == groupingTimestampDateComponents.minute &&
                    dateComponents.second == groupingTimestampDateComponents.second);
            break;
    }
    return NO;
}

#pragma mark - ComparableTreeNode protocol methods

- (NSComparisonResult)compare:(DateGroupingNodeData *)otherObject
{
    if (self.groupingTimestamp == otherObject.groupingTimestamp)
    {
        return NSOrderedSame;
    }
    if (self.groupingTimestamp == nil)
    {
        return NSOrderedDescending;
    }
    if (otherObject == nil || otherObject.groupingTimestamp == nil)
    {
        // Assume nil objects come "after" all other objects.
        return NSOrderedAscending;
    }
    
    return [self.groupingTimestamp compare:otherObject.groupingTimestamp];
}

#pragma mark - NSObject override methods

- (NSString *)description
{
    return self.groupingName;
//    
//    NSMutableString *string = [NSMutableString new];
//    
//    switch (self.groupingLevel)
//    {
//        case kDateGroupingLevelYear:
//            [string appendFormat:@"Grouping: Year %d [%@]", groupingTimestampDateComponents.year, self.groupingName];
//            break;
//        case kDateGroupingLevelMonth:
//            [string appendFormat:@"Grouping: Month %d [%@]", groupingTimestampDateComponents.month, self.groupingName];
//            break;
//        case kDateGroupingLevelDay:
//            [string appendFormat:@"Grouping: Day %d [%@]", groupingTimestampDateComponents.day, self.groupingName];
//            break;
//        case kDateGroupingLevelAtomic:
//            [string appendFormat:@"Atomic: [%@]", self.groupingName];
//            break;
//    }
//    
//    return string;
}

@end



@implementation CapturedContextDateBasedGrouper

@synthesize groupingRootNode;

- (id)init
{
    self = [super init];
    if (self)
    {
        [self reset];
    }
    return self;
}

#pragma mark - Public instance methods

- (void)reset
{
    self->groupingRootNode = [[TreeNode alloc] initWithData:nil sortOrder:kTreeNodeChildrenSortOrderDescending];
}

- (void)addCapturedContext:(CapturedContext *)capturedContext
{
    NSDate *timestamp = capturedContext.timestamp;
    
    // First get the year grouping node
    TreeNode *yearNode = [self findOrCreateImmediateGroupingNodeUnderParentNode:self.groupingRootNode forLevel:kDateGroupingLevelYear withTimestamp:timestamp];
    
    // Next get the month grouping node
    TreeNode *monthNode = [self findOrCreateImmediateGroupingNodeUnderParentNode:yearNode forLevel:kDateGroupingLevelMonth withTimestamp:timestamp];
    
    // Next get the day grouping node
    TreeNode *dayNode = [self findOrCreateImmediateGroupingNodeUnderParentNode:monthNode forLevel:kDateGroupingLevelDay withTimestamp:timestamp];

    TreeNode *leafNode = [[TreeNode alloc] initWithData:[[DateGroupingNodeData alloc] initWithLevel:kDateGroupingLevelAtomic timestamp:capturedContext.timestamp capturedContext:capturedContext]];
    [dayNode addChildNode:leafNode];
}

- (void)removeCapturedContext:(CapturedContext *)capturedContext
{
    TreeNode *targetNode = [self findNodeWithCapturedContext:capturedContext inSubtree:self.groupingRootNode];
    if (targetNode != nil)
    {
        TreeNode *oldParent = targetNode.parentNode;
        [targetNode removeFromParentNode];
        
        // Check to see if the removal of this CapturedContext has resulted
        // in any lone subgroups, in which case remove them as well.
        [self inspectAndPruneEmptyGroupingNode:oldParent];
    }
}

#pragma mark - Private instance methods

- (void)inspectAndPruneEmptyGroupingNode:(TreeNode *)nodeToInspect
{
    if (nodeToInspect != nil && !nodeToInspect.isRootNode &&
        [nodeToInspect.data isKindOfClass:[DateGroupingNodeData class]] &&
        nodeToInspect.numChildNodes == 0)
    {
        TreeNode *oldParent = nodeToInspect.parentNode;
        [nodeToInspect removeFromParentNode];
        [self inspectAndPruneEmptyGroupingNode:oldParent];
    }
}

- (TreeNode *)findNodeWithCapturedContext:(CapturedContext *)capturedContext inSubtree:(TreeNode *)subtreeRootNode
{
    if ([subtreeRootNode.data isKindOfClass:[DateGroupingNodeData class]])
    {
        CapturedContext *candidateCapturedContext = ((DateGroupingNodeData *)subtreeRootNode.data).capturedContext;
        
        if (candidateCapturedContext == capturedContext)
        {
            return subtreeRootNode;
        }
    }
    
    for (TreeNode *childNode in subtreeRootNode.childNodes)
    {
        TreeNode *candidateNode = [self findNodeWithCapturedContext:capturedContext inSubtree:childNode];
        if (candidateNode != nil)
        {
            return candidateNode;
        }
    }
    return nil;
}

- (TreeNode *)findOrCreateImmediateGroupingNodeUnderParentNode:(TreeNode *)parentNode forLevel:(DateGroupingLevel)groupingLevel withTimestamp:(NSDate *)timestamp
{
    TreeNode *groupingNode = nil;

    for (TreeNode *node in parentNode.childNodes)
    {
        if ([node.data isKindOfClass:[DateGroupingNodeData class]])
        {
            DateGroupingNodeData *groupingInfo = (DateGroupingNodeData *)node.data;
            if (groupingInfo.groupingLevel == groupingLevel &&
                [groupingInfo containsTime:timestamp])
            {
                groupingNode = node;
                break;
            }
        }
    }
    if (groupingNode == nil)
    {
        // Corresponding year node was not found so create one.
        DateGroupingNodeData *groupingInfo = [[DateGroupingNodeData alloc] initWithLevel:groupingLevel timestamp:timestamp];
        groupingNode = [[TreeNode alloc] initWithData:groupingInfo];
        [parentNode addChildNode:groupingNode];
    }
    
    return groupingNode;
}

@end
