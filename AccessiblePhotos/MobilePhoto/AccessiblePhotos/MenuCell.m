//
//  MenuCell.m
//  NewAppPrototype
//
//  Created by Adams Dustin on 12/07/12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MenuCell.h"

@implementation MenuCell
@synthesize dateLabel = _dateLabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
