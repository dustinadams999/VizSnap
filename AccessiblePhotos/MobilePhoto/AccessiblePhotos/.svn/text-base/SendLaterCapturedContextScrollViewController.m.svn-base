//
//  SendLaterCapturedContextScrollViewController.m
//  NewAppPrototype
//
//  Created by 原田 丞 on 12/07/16.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "SendLaterCapturedContextScrollViewController.h"
#import "CapturedContext.h"
#import "CapturedContextManager.h"

@implementation SendLaterCapturedContextScrollViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mainTitle = @"To send";
}

#pragma mark - CapturedContextScrollViewController overrides

- (NSArray *)updateCapturedContextList
{
    //since we now have the unique date of the cell that was pressed, we will use that to grab all the CapturedContexts from the CapturedContextManager that match that date and put them into an array
    NSMutableArray *sendLaterCapturedContexts = [NSMutableArray new];
    
    for (CapturedContext *capturedContext in [CapturedContextManager sharedManager].capturedContexts)
    {
        if (capturedContext.taggedForSending)
        {
            [sendLaterCapturedContexts addObject:capturedContext];
        }
    }
    
    return sendLaterCapturedContexts;
}

@end
