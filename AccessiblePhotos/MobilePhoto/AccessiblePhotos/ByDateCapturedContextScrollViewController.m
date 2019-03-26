//
//  ByDateCapturedContextScrollViewController.m
//  NewAppPrototype
//
//  Created by 原田 丞 on 12/07/16.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "ByDateCapturedContextScrollViewController.h"
#import "CapturedContext.h"
#import "CapturedContextManager.h"

@implementation ByDateCapturedContextScrollViewController

@synthesize filterByDate;

#pragma mark - CapturedContextScrollViewController overrides

- (NSArray *)updateCapturedContextList
{
    
    //since we now have the unique date of the cell that was pressed, we will use that to grab all the CapturedContexts from the CapturedContextManager that match that date and put them into an array
    NSMutableArray *filteredCapturedContexts = [NSMutableArray new];
    NSDateComponents *components;
    NSDateComponents *components2;
    for (CapturedContext *capturedContext in [CapturedContextManager sharedManager].capturedContexts)
    {
        components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:capturedContext.timestamp];
        components2 = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:self.filterByDate];
        if (([components day] == [components2 day]) && ([components month] == [components2 month]) && ([components year] == [components2 year]))
        {
            [filteredCapturedContexts addObject:capturedContext];
        }
    }
    
    return filteredCapturedContexts;
}

@end
