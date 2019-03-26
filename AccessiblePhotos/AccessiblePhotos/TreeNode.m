//
//  TreeNode.m
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/08/02.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "TreeNode.h"

@implementation TreeNode
{
    NSMutableArray *_childNodes;
    
    TreeNodeChildrenSortOrder sortOrder;
    
    uint numSubtreeNodes;
    uint numSubtreeLeaves;

    BOOL numSubtreeNodesNeedsUpdate;
    BOOL numSubtreeLeavesNeedsUpdate;
}

@synthesize parentNode = _parentNode;
@synthesize rootNode = _rootNode;
@synthesize data;

- (id)init
{
    return [self initWithData:nil];
}

- (id)initWithData:(id)nodeData
{
    return [self initWithData:nodeData sortOrder:kTreeNodeChildrenSortOrderUnsorted];
}

- (id)initWithData:(id)nodeData sortOrder:(TreeNodeChildrenSortOrder)aSortOrder
{
    self = [super init];
    if (self)
    {
        _childNodes = [NSMutableArray new];
        self.data = nodeData;
        sortOrder = aSortOrder;
    }
    return self;
}

#pragma mark - Property accessor methods

- (NSArray *)childNodes
{
    return [NSArray arrayWithArray:_childNodes];
}

- (NSArray *)leafNodes
{
    NSMutableArray *leafNodes = [NSMutableArray new];
    
    if (!self.isLeafNode)
    {
        for (TreeNode *childNode in self.childNodes)
        {
            if (childNode.isLeafNode)
            {
                [leafNodes addObject:childNode];
            }
            else
            {
                [leafNodes addObjectsFromArray:childNode.leafNodes];
            }
        }
    }
    
    return [NSArray arrayWithArray:leafNodes];
}

- (BOOL)isLeafNode
{
    return (self.numChildNodes == 0);
}

- (BOOL)isRootNode
{
    return self.parentNode == nil;
}

- (uint)numChildNodes
{
    return _childNodes.count;
}

- (uint)numSubtreeNodes
{
    if (numSubtreeNodesNeedsUpdate)
    {
        numSubtreeNodes = 1;
        if (self.isLeafNode == NO)
        {
            for (TreeNode *childNode in _childNodes)
            {
                numSubtreeNodes += childNode.numSubtreeNodes;
            }
        }
        numSubtreeNodesNeedsUpdate = NO;
    }
    return numSubtreeNodes;
}

- (uint)numSubtreeLeaves
{
    if (self.isLeafNode)
    {
        return 1;
    }
    
    if (numSubtreeLeavesNeedsUpdate)
    {
        numSubtreeLeaves = 0;
        for (TreeNode *childNode in _childNodes)
        {
            numSubtreeLeaves += childNode.numSubtreeLeaves;
        }
        numSubtreeLeavesNeedsUpdate = NO;
    }
    return numSubtreeLeaves;
}

- (uint)depthFromRootNode
{
    if (self.isRootNode)
    {
        return 0;
    }
    return 1 + self.parentNode.depthFromRootNode;
}

#pragma mark - Public instance methods

- (TreeNode *)childAtIndex:(uint)index
{
    return [_childNodes objectAtIndex:index];
}

- (void)addChildNode:(TreeNode *)childNode
{
    [self addChildNode:childNode propagateSortOrder:YES];
}

- (void)addChildNode:(TreeNode *)childNode propagateSortOrder:(BOOL)propagateSortOrder
{
    [_childNodes addObject:childNode];
    childNode->_parentNode = self;
    [self sortChildrenRecursively:propagateSortOrder];
    [self subtreeStructureChanged];
}

- (void)removeChildNode:(TreeNode *)childNode
{
    TreeNode *oldParent = childNode->_parentNode;
    childNode->_parentNode = nil;
    [_childNodes removeObject:childNode];
    
    [oldParent subtreeStructureChanged];
}

- (void)removeChildNodeAt:(uint)index
{
    TreeNode *childNode = [_childNodes objectAtIndex:index];
    [self removeChildNode:childNode];
}

- (void)removeFromParentNode
{
    if (self.isRootNode == NO)
    {
        [self.parentNode removeChildNode:self];
    }
}

- (NSString *)description
{
    NSMutableString *string = [NSMutableString new];
    
    NSMutableString *prefix = [NSMutableString new];
    for (int i = 0; i < self.depthFromRootNode; i++)
    {
        [prefix appendString:@"|"];
    }
    
    [string appendFormat:@"%@-%@\n", prefix, self.data];
    [string appendFormat:@"%@  (Type: %@ children: %d leaves: %d nodes: %d)\n",
     prefix, (self.isRootNode ? @"Root" : self.isLeafNode ? @"Leaf" : @"Node"),
     self.numChildNodes, self.numSubtreeLeaves, self.numSubtreeNodes];
    
    for (TreeNode *childNode in self.childNodes)
    {
        [string appendFormat:@"%@", childNode];
    }
    
    return string;
}

- (void)setSortOrder:(TreeNodeChildrenSortOrder)aSortOrder recursively:(BOOL)recursively
{
    if (sortOrder != aSortOrder)
    {
        sortOrder = aSortOrder;
        [self sortChildrenRecursively:recursively];
    }
}

- (TreeNodeChildrenSortOrder)sortOrder
{
    return sortOrder;
}

#pragma mark - Private instance methods

- (void)subtreeStructureChanged
{
    numSubtreeLeavesNeedsUpdate = YES;
    numSubtreeNodesNeedsUpdate = YES;
    if (self.parentNode != nil)
    {
        [self.parentNode subtreeStructureChanged];
    }
}

- (void)sortChildrenRecursively:(BOOL)recursively
{
    if (sortOrder != kTreeNodeChildrenSortOrderUnsorted && self.numChildNodes > 1)
    {
        // Sort the children
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"data"
                                                                       ascending:(sortOrder == kTreeNodeChildrenSortOrderAscending)];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        [_childNodes sortUsingDescriptors:sortDescriptors];
    }

    if (recursively)
    {
        for (TreeNode *child in self.childNodes)
        {
            [child setSortOrder:sortOrder recursively:YES];
        }
    }
}

#pragma mark - NSCopying protocol method

- (id)copyWithZone:(NSZone *)zone
{
    TreeNode *copiedNode = [[TreeNode allocWithZone:zone] initWithData:self.data sortOrder:self.sortOrder];
    
    for (TreeNode *childNode in self.childNodes)
    {
        [copiedNode addChildNode:[childNode copy] propagateSortOrder:NO];
    }
    
    return copiedNode;
}

@end
