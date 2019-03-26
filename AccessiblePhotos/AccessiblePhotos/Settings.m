//
//  Settings.m
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/07/24.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "Settings.h"

@implementation Settings

@synthesize interfaceType = _interfaceType;

@synthesize useWithoutLoggingIn = _useWithoutLoggingIn;
@synthesize alwaysStartInCameraView = _alwaysStartInCameraView;
@synthesize useCameraGestures = _useCameraGestures;

@synthesize saveLocationInfo = _saveLocationInfo;
@synthesize saveCompassInfo = _saveCompassInfo;

@synthesize requestSendingEnabled = _requestSendingEnabled;

@synthesize faceDetectionEnabled = _faceDetectionEnabled;

@synthesize maxAmbientAudioRecordingDuration = _maxAmbientAudioRecordingDuration;

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
    id interfaceType = [[NSUserDefaults standardUserDefaults] objectForKey:@"interfaceType"];
    if (interfaceType == nil) {
        interfaceType = [NSNumber numberWithInt:kInterfaceTypeStandard];
    }
    _interfaceType = [interfaceType intValue];
    
    id useWithoutLoggingIn = [[NSUserDefaults standardUserDefaults] objectForKey:@"useWithoutLoggingIn"];
    if (useWithoutLoggingIn == nil) {
        useWithoutLoggingIn = [NSNumber numberWithBool:YES];
    }
    self.useWithoutLoggingIn = [useWithoutLoggingIn boolValue];

    id alwaysStartInCameraView = [[NSUserDefaults standardUserDefaults] objectForKey:@"alwaysStartInCameraView"];
    if (alwaysStartInCameraView == nil) {
        alwaysStartInCameraView = [NSNumber numberWithBool:NO];
    }
    self.alwaysStartInCameraView = [alwaysStartInCameraView boolValue];
    
    id useCameraGestures = [[NSUserDefaults standardUserDefaults] objectForKey:@"useCameraGestures"];
    if (useCameraGestures == nil) {
        useCameraGestures = [NSNumber numberWithBool:YES];
    }
    self.useCameraGestures = [useCameraGestures boolValue];
    
    id saveLocationInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"saveLocationInfo"];
    if (saveLocationInfo == nil) {
        saveLocationInfo = [NSNumber numberWithBool:YES];
    }
    self.saveLocationInfo = [saveLocationInfo boolValue];
    
    id saveCompassInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"saveCompassInfo"];
    if (saveCompassInfo == nil) {
        saveCompassInfo = [NSNumber numberWithBool:NO];
    }
    self.saveCompassInfo = [saveCompassInfo boolValue];
    
    id requestSendingEnabled = [[NSUserDefaults standardUserDefaults] objectForKey:@"requestSendingEnabled"];
    if (requestSendingEnabled == nil) {
        requestSendingEnabled = [NSNumber numberWithBool:NO];
    }
    self.requestSendingEnabled = [requestSendingEnabled boolValue];
    
    id faceDetectionEnabled = [[NSUserDefaults standardUserDefaults] objectForKey:@"faceDetectionEnabled"];
    if (faceDetectionEnabled == nil) {
        faceDetectionEnabled = [NSNumber numberWithBool:YES];
    }
    self.faceDetectionEnabled = [faceDetectionEnabled boolValue];
    
    id maxAmbientAudioRecordingDuration = [[NSUserDefaults standardUserDefaults] objectForKey:@"maxAmbientAudioRecordingDuration"];
    if (maxAmbientAudioRecordingDuration == nil) {
        maxAmbientAudioRecordingDuration = [NSNumber numberWithDouble:10.0];
    }
    self.maxAmbientAudioRecordingDuration = [maxAmbientAudioRecordingDuration doubleValue];
}

- (void)saveSettings
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:self.interfaceType] forKey:@"interfaceType"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.useWithoutLoggingIn] forKey:@"useWithoutLoggingIn"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.alwaysStartInCameraView] forKey:@"alwaysStartInCameraView"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.useCameraGestures] forKey:@"useCameraGestures"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.saveLocationInfo] forKey:@"saveLocationInfo"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.saveCompassInfo] forKey:@"saveCompassInfo"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.requestSendingEnabled] forKey:@"requestSendingEnabled"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.faceDetectionEnabled] forKey:@"faceDetectionEnabled"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:self.maxAmbientAudioRecordingDuration] forKey:@"maxAmbientAudioRecordingDuration"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
