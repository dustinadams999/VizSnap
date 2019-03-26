//
//  TreeNode.h
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/08/02.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ComparableTreeNode <NSObject>

- (NSComparisonResult)compare:(id)otherObject;

@end

typedef enum
{
    kTreeNodeChildrenSortOrderUnsorted,
    kTreeNodeChildrenSortOrderAscending,
    kTreeNodeChildrenSortOrderDescending
} TreeNodeChildrenSortOrder;

@interface TreeNode : NSObject <NSCopying>

@property (nonatomic, readonly) BOOL isLeafNode;
@property (nonatomic, readonly) BOOL isRootNode;
@property (nonatomic, weak, readonly) TreeNode *parentNode;
@property (nonatomic, weak, readonly) TreeNode *rootNode;
@property (nonatomic, strong) id<ComparableTreeNode> data;
@property (nonatomic, strong, readonly) NSArray *childNodes;
@property (nonatomic, strong, readonly) NSArray *leafNodes;

@property (nonatomic, readonly) uint numChildNodes;
@property (nonatomic, readonly) uint numSubtreeNodes;
@property (nonatomic, readonly) uint numSubtreeLeaves;
@property (nonatomic, readonly) uint depthFromRootNode;

- (id)initWithData:(id<ComparableTreeNode>)nodeData;
- (id)initWithData:(id<ComparableTreeNode>)nodeData sortOrder:(TreeNodeChildrenSortOrder)sortOrder;

- (TreeNode *)childAtIndex:(uint)index;
- (void)addChildNode:(TreeNode *)childNode;
- (void)addChildNode:(TreeNode *)childNode propagateSortOrder:(BOOL)propagateSortOrder;
- (void)removeChildNode:(TreeNode *)childNode;
- (void)removeChildNodeAt:(uint)index;
- (void)removeFromParentNode;

- (void)setSortOrder:(TreeNodeChildrenSortOrder)sortOrder recursively:(BOOL)recursively;
- (TreeNodeChildrenSortOrder)sortOrder;

- (id)copyWithZone:(NSZone *)zone;

@end
