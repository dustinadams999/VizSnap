//
//  LocationManager.m
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/07/19.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import "LocationManager.h"

@interface LocationManager () <CLLocationManagerDelegate>

@end

@implementation LocationManager
{
    CLLocationManager *locationManager;
}

@synthesize location = _location;
@synthesize heading = _heading;

+ (LocationManager *)sharedManager
{
    static dispatch_once_t pred;
    static LocationManager *sharedInstance = nil;
    dispatch_once(&pred, ^{ sharedInstance = [self new]; });
    return sharedInstance;
}

- (id)init
{
    if (self = [super init])
    {
        locationManager = [CLLocationManager new];
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        locationManager.delegate = self;
    }
    return self;
}

- (void)start
{
    [locationManager startUpdatingLocation];
    [locationManager startUpdatingHeading];
}

- (void)stop
{
    [locationManager stopUpdatingHeading];
    [locationManager stopUpdatingLocation];
    _location = nil;
    _heading = nil;
}

#pragma mark - CLLocationManagerDelegate

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    _location = [newLocation copy];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    _heading = [newHeading copy];
}

@end
