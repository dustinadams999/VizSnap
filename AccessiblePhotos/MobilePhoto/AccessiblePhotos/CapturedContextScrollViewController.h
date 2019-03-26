//
//  DateScrollViewController.h
//  NewAppPrototype
//
//  Created by Adams Dustin on 12/07/12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CapturedContextScrollViewController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic, copy) NSString *mainTitle;

- (NSArray *)updateCapturedContextList;

@end
