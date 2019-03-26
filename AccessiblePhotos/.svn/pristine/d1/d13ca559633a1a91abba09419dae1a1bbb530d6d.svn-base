//
//  ByDateAudioPreviewViewController.m
//  AccessiblePhotos
//
//  Created by Adams Dustin on 7/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ByDateAudioPreviewViewController.h"
#import "CapturedContext.h"
#import "CapturedContextManager.h"
#import "CapturedContextDateBasedGrouper.h"

@implementation ByDateAudioPreviewViewController

//@synthesize filterByDate;
//@synthesize dayNode;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.isByDate = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([super.rootNode.data isKindOfClass:[DateGroupingNodeData class]])
    {
        DateGroupingNodeData *data = super.rootNode.data;
        self.title = [NSDateFormatter localizedStringFromDate:data.groupingTimestamp dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
}

}

#pragma AudioPreviewViewController overrides

- (NSArray *)updateCapturedContextList
{
    //since we now have the unique date of the cell that was pressed, we will use that to grab all the CapturedContexts from the CapturedContextManager that match that date and put them into an array

    if (super.rootNode.isRootNode)
    {
        // FIX: temporary way to know if this day note has been removed.
        return [NSArray new];
    }
    return super.rootNode.leafNodes;
}
//- (NSArray *)updateCapturedContextList
//{
//    //since we now have the unique date of the cell that was pressed, we will use that to grab all the CapturedContexts from the CapturedContextManager that match that date and put them into an array
//    
//    NSMutableArray *filteredCapturedContexts = [NSMutableArray new];
//    NSDateComponents *components;
//    NSDateComponents *components2;
//    components2 = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:self.filterByDate];    
//    for (CapturedContext *capturedContext in [CapturedContextManager sharedManager].capturedContexts)
//    {
//        components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:capturedContext.timestamp];
//        if (([components day] == [components2 day]) && ([components month] == [components2 month]) && ([components year] == [components2 year]))
//        {
//            [filteredCapturedContexts addObject:capturedContext];
//        }
//    }
//    
//    return [super sortKeys:filteredCapturedContexts];
//}

@end
