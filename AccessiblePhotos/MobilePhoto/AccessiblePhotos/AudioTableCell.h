//
//  AudioTableCell.h
//  AccessiblePhotos
//
//  Created by Adams Dustin on 7/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CapturedContext.h"

@class AudioTableCell;

@protocol AudioTableCellDelegate <NSObject>

-(void)audioTableCellAccessibilityElementDidBecomeFocused:(CapturedContext *)sender;
-(void)audioTableCellAccessibilityElementDidLoseFocus:(CapturedContext *)sender;

@end

@interface AudioTableCell : UITableViewCell

@property (nonatomic, weak) id<AudioTableCellDelegate> delegate;
@property (nonatomic, weak) CapturedContext *capturedContext;
@property (nonatomic, strong) IBOutlet UIImageView *image;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;
-(IBAction)pressPlay;

@end