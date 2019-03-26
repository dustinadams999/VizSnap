//
//  User.h
//  TurnByTurn
//
//  Created by 原田 丞 on 12/04/02.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "UserRequest.h"

@interface User : NSObject

@property (nonatomic, copy) NSString *credential;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, strong) NSMutableArray *unansweredRequests;
@property (nonatomic, strong) NSMutableArray *answeredRequests;

@property (nonatomic, strong, readonly) NSArray *supporterGroups;

- (id)initWithUserId:(NSString *)userId credential:(NSString *)credential supporterGroups:(NSArray *)supporterGroups;
- (void)saveUserData;

@end
