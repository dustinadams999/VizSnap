//
//  Settings.h
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/07/24.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    kInterfaceTypeStandard,
    kInterfaceTypeExperimental
} InterfaceType;


@interface Settings : NSObject

@property (nonatomic, readonly) InterfaceType interfaceType;

@property (nonatomic, assign) BOOL useWithoutLoggingIn;
@property (nonatomic, assign) BOOL alwaysStartInCameraView;
@property (nonatomic, assign) BOOL useCameraGestures;

@property (nonatomic, assign) BOOL saveLocationInfo;
@property (nonatomic, assign) BOOL saveCompassInfo;

@property (nonatomic, assign) BOOL requestSendingEnabled;

@property (nonatomic, assign) BOOL faceDetectionEnabled;

@property (nonatomic, assign) NSTimeInterval maxAmbientAudioRecordingDuration;

+ (Settings *)sharedInstance;

- (void)loadSettings;
- (void)saveSettings;

@end
