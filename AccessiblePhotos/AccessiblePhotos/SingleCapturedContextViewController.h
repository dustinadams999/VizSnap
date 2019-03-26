//
//  SingleCapturedContextViewController.h
//  AccessiblePhotos
//
//  Created by Adams Dustin on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CapturedContext.h"
#import "CapturedContextManager.h"
#import "ByDateTableViewController.h"

@interface SingleCapturedContextViewController : UIViewController

@property (nonatomic, weak) CapturedContext *capturedContext;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) IBOutlet UILabel *locationLabel;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
- (IBAction)deleteCurrentCapturedContext:(id)sender;
- (IBAction)playAudio;

@end
