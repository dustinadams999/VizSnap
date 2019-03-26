//
//  CapturedContext.h
//  NewAppPrototype
//
//  Created by 原田 丞 on 12/07/12.
//  Copyright (c) 2012年 IBM Research - Tokyo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CapturedContext : NSObject <NSCoding>

@property (nonatomic, copy, readonly) NSDate *timestamp;
@property (nonatomic, strong) UIImage *uiImage;
@property (nonatomic, copy, readonly) NSString *photoFilePath;
@property (nonatomic, copy, readonly) NSString *audioFilePath;
@property (nonatomic, copy, readonly) NSString *memoFilePath;
@property (nonatomic, readonly) BOOL photoFileExists;
@property (nonatomic, readonly) BOOL audioFileExists;
@property (nonatomic) BOOL taggedForSending;
@property (nonatomic) BOOL hasMemo;

@property (nonatomic, readonly) CLLocation *location;
@property (nonatomic, readonly) CLHeading *heading;

@property (nonatomic, readonly) CLPlacemark *placemark;

- (id)initWithTimestamp:(NSDate *)timestamp location:(CLLocation *)location heading:(CLHeading *)heading placemark:(CLPlacemark *)placemark taggedForSending:(BOOL)taggedForSending;

@end
