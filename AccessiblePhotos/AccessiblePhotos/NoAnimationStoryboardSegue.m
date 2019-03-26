//
//  NoAnimationStoryboardSegue.m
//  NewAppPrototype
//
//  Created by 原田 丞 on 12/07/13.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "NoAnimationStoryboardSegue.h"

@implementation NoAnimationStoryboardSegue

- (void)perform
{
    [self.sourceViewController presentModalViewController:self.destinationViewController animated:NO];
}

@end
