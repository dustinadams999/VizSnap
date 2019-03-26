//
//  SearchAudioPreviewViewController.h
//  AccessiblePhotos
//
//  Created by Dustin Adams on 2/20/14.
//
//

#import <UIKit/UIKit.h>
#import "TreeNode.h"

@interface SearchAudioPreviewViewController : UITableViewController

@property (nonatomic, copy) NSString *mainTitle;
@property (nonatomic, weak) TreeNode *rootNode;

@end
