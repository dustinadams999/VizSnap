//
//  VolumeButtonListener.h
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/07/27.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VolumeButtonListener;

@protocol VolumeButtonListenerDelegate <NSObject>

@optional

- (void)volumeButtonListenerVolumeUpPressed:(VolumeButtonListener *)listener;
- (void)volumeButtonListenerVolumeDownPressed:(VolumeButtonListener *)listener;

@end

@interface VolumeButtonListener : NSObject

@property (nonatomic, retain) id<VolumeButtonListenerDelegate> delegate;

- (void)start;
- (void)stop;

@end
