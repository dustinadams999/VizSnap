//
//  ToSendAudioPreviewViewController.m
//  AccessiblePhotos
//
//  Created by Adams Dustin on 7/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ToSendAudioPreviewViewController.h"
#import "CapturedContext.h"
#import "CapturedContextManager.h"
#import "CapturedContextDateBasedGrouper.h"

@implementation ToSendAudioPreviewViewController

- (NSArray *)updateCapturedContextList
{
    NSMutableArray *toSendNodes = [NSMutableArray new];
    
    for (TreeNode *node in [CapturedContextManager sharedManager].dateBasedGroupingRoot.leafNodes)
    {
        if ([node.data isKindOfClass:[DateGroupingNodeData class]])
        {
            CapturedContext *capturedContext = ((DateGroupingNodeData *)node.data).capturedContext;
            if (capturedContext != nil && capturedContext.taggedForSending)
            {
                [toSendNodes addObject:node];
            }
        }
    }
    return toSendNodes;
}
//- (NSArray *)updateCapturedContextList
//{
//    //since we now have the unique date of the cell that was pressed, we will use that to grab all the CapturedContexts from the CapturedContextManager that match that date and put them into an array
//    NSMutableArray *filteredCapturedContexts = [NSMutableArray new];
//    
//    for (CapturedContext *capturedContext in [CapturedContextManager sharedManager].capturedContexts)
//    {
//        if (capturedContext.taggedForSending)
//        {
//            [filteredCapturedContexts addObject:capturedContext];            
//        }
//    }
//    
//    return [super sortKeys:filteredCapturedContexts];
//}

@end
