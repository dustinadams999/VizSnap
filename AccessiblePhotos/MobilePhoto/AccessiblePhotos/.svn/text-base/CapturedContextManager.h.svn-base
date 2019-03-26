//
//  CapturedContextManager.h
//  NewAppPrototype
//
//  Created by 原田 丞 on 12/07/12.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CapturedContextManager : NSObject

@property (nonatomic, readonly) NSMutableArray *capturedContexts;

+ (CapturedContextManager *)sharedManager;

- (void)reloadCapturedContextList;
- (void)saveCapturedContextList;

@end
