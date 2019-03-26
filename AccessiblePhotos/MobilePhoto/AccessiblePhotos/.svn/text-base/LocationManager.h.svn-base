//
//  LocationManager.h
//  AccessiblePhotos
//
//  Created by 原田 丞 on 12/07/19.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject

@property (nonatomic, readonly) CLLocation *location;
@property (nonatomic, readonly) CLHeading *heading;

+ (LocationManager *)sharedManager;

- (void)start;
- (void)stop;

@end
