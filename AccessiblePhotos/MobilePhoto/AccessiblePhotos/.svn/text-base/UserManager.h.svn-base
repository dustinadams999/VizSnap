//
//  UserDataManager.h
//  WhatIsThis
//
//  Created by 原田 丞 on 12/03/07.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import <CoreLocation/CoreLocation.h>
#import "User.h"

typedef void (^FavoritePOIsFetcherCallback)();

@interface UserManager : NSObject

@property (nonatomic, readonly, strong) User* currentUser;

+ (UserManager*)sharedManager;

- (void)authenticateWithUserID:(NSString*)userID password:(NSString*)password callback:(void (^)(User*, NSString*))callback;
- (void)logoutCurrentUser;

@end
