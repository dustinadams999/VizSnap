//
//  GenericViewController.h
//  AccessiblePhotos
//
//  Created by Adams Dustin on 7/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CapturedContext.h"
#import "CapturedContextManager.h"

@interface GenericViewController : UITableViewController

@property BOOL byLocation;
@property BOOL byMonth;
@property BOOL byDate;
@property BOOL byTime;

@end
