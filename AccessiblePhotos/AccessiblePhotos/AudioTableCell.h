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

-(void)audioTableCell:(AudioTableCell *)sender startPlayingAudioOfCapturedContext:(CapturedContext *)capturedContext;
-(void)audioTableCell:(AudioTableCell *)sender stopPlayingAudioOfCapturedContext:(CapturedContext *)capturedContext;

@end

@interface AudioTableCell : UITableViewCell

@property (nonatomic, weak) CapturedContext *capturedContext;
@property (nonatomic, readonly) int rowIndex;
@property (nonatomic, readonly) int totalRowCount;
@property (nonatomic, weak) id<AudioTableCellDelegate> delegate;

- (void)setCapturedContext:(CapturedContext *)capturedContext rowIndex:(int)rowIndex totalRowCount:(int)totalRowCount;

- (void)audioStopped;
- (void)audioFinishedPlaying;

@end