//
//  CapturedContextManager.h
//  NewAppPrototype
//
//  Created by 原田 丞 on 12/07/12.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CapturedContext.h"
#import "TreeNode.h"

@interface CapturedContextManager : NSObject

@property (nonatomic, readonly) NSArray *capturedContexts;
@property (nonatomic, strong, readonly) TreeNode *dateBasedGroupingRoot;

+ (CapturedContextManager *)sharedManager;

- (void)reloadCapturedContextList;
- (void)saveCapturedContextList;
- (void)addCapturedContext:(CapturedContext *)capturedContext;
- (void)permanentlyDeleteCapturedContext:(CapturedContext *)capturedContext;
- (void)permanentlyDeleteAllCapturedContexts;

@end
