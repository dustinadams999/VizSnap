//
//  Settings.m
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/07/24.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "Settings.h"

@implementation Settings

@synthesize alwaysStartInCameraView = _alwaysStartInCameraView;
@synthesize useCameraGestures = _useCameraGestures;

+ (Settings *)sharedInstance
{
    static dispatch_once_t pred;
    static Settings* sharedInstance = nil;
    dispatch_once(&pred, ^{ sharedInstance = [self new]; });
    return sharedInstance;
}

- (id)init
{
    if (self = [super init])
    {
        [self loadSettings];
    }
    return self;
}

- (void)loadSettings
{
    id alwaysStartInCameraView = [[NSUserDefaults standardUserDefaults] objectForKey:@"alwaysStartInCameraView"];
    if (alwaysStartInCameraView == nil) {
        alwaysStartInCameraView = [NSNumber numberWithBool:NO];
    }
    self.alwaysStartInCameraView = [alwaysStartInCameraView boolValue];

    id useCameraGestures = [[NSUserDefaults standardUserDefaults] objectForKey:@"useCameraGestures"];
    if (useCameraGestures == nil) {
        useCameraGestures = [NSNumber numberWithBool:NO];
    }
    self.useCameraGestures = [useCameraGestures boolValue];
}

- (void)saveSettings
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.alwaysStartInCameraView] forKey:@"alwaysStartInCameraView"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.useCameraGestures] forKey:@"useCameraGestures"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
