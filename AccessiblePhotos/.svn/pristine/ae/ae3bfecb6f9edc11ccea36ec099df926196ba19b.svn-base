//
//  LoginViewController.h
//  NewAppPrototype
//
//  Created by 原田 丞 on 12/07/13.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@class LoginViewController;

@protocol LoginViewControllerDelegate <NSObject>

- (void)loginViewController:(LoginViewController *)controller loggedInUser:(User *)user;
- (void)loginViewControllerUseWithoutLoggingIn:(LoginViewController *)controller;

@end

@interface LoginViewController : UIViewController

@property (nonatomic, weak) id<LoginViewControllerDelegate> delegate;

@end
