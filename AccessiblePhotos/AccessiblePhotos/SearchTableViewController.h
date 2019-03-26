//
//  SearchTableViewController.h
//  AccessiblePhotos
//
//  Created by Dustin Adams on 2/20/14.
//
//

#import <UIKit/UIKit.h>
#import "CapturedContext.h"
#import "CapturedContextManager.h"
#import "SingleCapturedContextViewController.h"

@interface SearchTableViewController : UITableViewController
@property (nonatomic, weak) TreeNode *uniqueMonthNode;
@end
