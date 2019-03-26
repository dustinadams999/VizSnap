//
//  AudioPreviewViewController.h
//  AccessiblePhotos
//
//  Created by Adams Dustin on 7/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TreeNode.h"

@interface AudioPreviewViewController : UITableViewController

@property (nonatomic, copy) NSString *mainTitle;
@property (nonatomic, weak) TreeNode *rootNode;

@end
